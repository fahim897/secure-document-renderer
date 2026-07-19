from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
from playwright.async_api import async_playwright
import os

app = FastAPI(title="Secure Document Renderer API")

class RenderRequest(BaseModel):
    html: str
    format: str = "pdf"  # "pdf" or "png"
    api_key: str

API_KEY = os.environ.get("RENDER_API_KEY", "SuperSecretRenderingKey2026")

@app.post("/render")
async def render_document(req: RenderRequest):
    if req.api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Unauthorized")
    
    try:
        async with async_playwright() as p:
            browser = await p.chromium.launch(
                headless=True,
                args=['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
            )
            context = await browser.new_context(
                viewport={"width": 1200, "height": 1600}
            )
            page = await context.new_page()
            
            # Write HTML to the page and wait for resources to load
            await page.set_content(req.html, wait_until="networkidle")
            
            # Emulate print media to apply print stylesheets
            await page.emulate_media(media="print")
            
            if req.format == "pdf":
                pdf_bytes = await page.pdf(
                    print_background=True,
                    format="A4",
                    margin={"top": "0px", "bottom": "0px", "left": "0px", "right": "0px"}
                )
                await browser.close()
                return Response(content=pdf_bytes, media_type="application/pdf")
                
            elif req.format == "png":
                image_bytes = await page.screenshot(
                    full_page=True,
                    type="png"
                )
                await browser.close()
                return Response(content=image_bytes, media_type="image/png")
            else:
                await browser.close()
                raise HTTPException(status_code=400, detail="Invalid format. Supported: pdf, png")
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
