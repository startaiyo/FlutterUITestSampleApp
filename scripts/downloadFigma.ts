import axios from 'axios';
import * as fs from 'fs';
import * as path from 'path';
import { URL } from 'url';

// Load environment variables if you are using dotenv
// require('dotenv').config(); 

interface FigmaImageResponse {
    err: string | null;
    images: {
        [key: string]: string | null;
    };
}

/**
 * Parses the Figma URL to extract File Key and Node ID
 */
function parseFigmaUrl(figmaUrl: string): { fileKey: string; nodeId: string } {
    try {
        const urlObj = new URL(figmaUrl);
        
        // 1. Extract File Key (Works for /file/ and /design/ URLs)
        // Regex matches segments like /design/KEY or /file/KEY
        const pathSegments = urlObj.pathname.split('/');
        const designIndex = pathSegments.findIndex(seg => seg === 'design' || seg === 'file');
        
        if (designIndex === -1 || !pathSegments[designIndex + 1]) {
            throw new Error('Could not find File Key in URL path');
        }
        const fileKey = pathSegments[designIndex + 1];

        // 2. Extract Node ID from query parameters
        const nodeId = urlObj.searchParams.get('node-id');
        if (!nodeId) {
            throw new Error("URL is missing '?node-id=...' query parameter");
        }

        return { fileKey, nodeId };
    } catch (error: any) {
        throw new Error(`Failed to parse URL: ${error.message}`);
    }
}

/**
 * Main function to download the image
 */
async function downloadFigmaImage(targetUrl: string, outputDir: string): Promise<void> {
    const token = process.env.FIGMA_ACCESS_TOKEN;

    if (!token) {
        console.error("❌ Error: FIGMA_ACCESS_TOKEN is not set.");
        process.exit(1);
    }

    try {
        console.log(`Parsing URL: ${targetUrl}`);
        const { fileKey, nodeId } = parseFigmaUrl(targetUrl);
        console.log(`   File Key: ${fileKey}`);
        console.log(`   Node ID:  ${nodeId}`);

        // --- Step 1: Get Image URL from Figma API ---
        const apiUrl = `https://api.figma.com/v1/images/${fileKey}`;
        
        console.log("Fetching image download link...");
        const response = await axios.get<FigmaImageResponse>(apiUrl, {
            headers: { 'X-Figma-Token': token },
            params: {
                ids: nodeId,
                format: 'png',
                scale: 2 // 2x for Retina quality
            }
        });

        // The API might return keys with colons instead of hyphens, so we check both
        const images = response.data.images;
        const imageUrl = images[nodeId] || images[nodeId.replace('-', ':')];

        if (!imageUrl) {
            throw new Error(`Figma returned no image URL for node ${nodeId}. Check permissions or if node is visible.`);
        }

        // --- Step 2: Download the actual image ---
        console.log(`Downloading image from S3...`);
        
        const writer = fs.createWriteStream(path.join(outputDir, 'selection.png'));
        
        const imageResponse = await axios({
            url: imageUrl,
            method: 'GET',
            responseType: 'stream'
        });

        // Ensure directory exists
        if (!fs.existsSync(outputDir)){
            fs.mkdirSync(outputDir, { recursive: true });
        }

        // Pipe the result to the file
        imageResponse.data.pipe(writer);

        return new Promise((resolve, reject) => {
            writer.on('finish', () => {
                console.log(`✅ Success! Image saved to: ${path.join(outputDir, 'selection.png')}`);
                resolve();
            });
            writer.on('error', reject);
        });

    } catch (error: any) {
        if (axios.isAxiosError(error)) {
            console.error(`❌ API Error: ${error.response?.status} - ${error.response?.statusText}`);
            console.error(`   Details: ${JSON.stringify(error.response?.data)}`);
        } else {
            console.error(`❌ Error: ${error.message}`);
        }
    }
}

// --- EXECUTION ---
const args = process.argv.slice(2);

if (args.length === 0) {
    console.error("❌ Error: No Figma URL provided.");
    console.error("");
    console.error("Usage:");
    console.error("  npx tsx scripts/downloadFigma.ts <figma_url> [output_dir]");
    console.error("");
    console.error("Example:");
    console.error("  npx tsx scripts/downloadFigma.ts 'https://www.figma.com/design/YSoR7FTfQm3rujz9RJWbAt/Desh?node-id=643-69'");
    console.error("  npx tsx scripts/downloadFigma.ts 'https://www.figma.com/design/...' ./custom/output/dir");
    process.exit(1);
}

const TARGET_URL = args[0];
const OUTPUT_DIR = args[1] || "./figma/images";

downloadFigmaImage(TARGET_URL, OUTPUT_DIR);