const { exec } = require( "child_process");
const http = require("http");
const Json = JSON;

const hostName = "0.0.0.0";
const port = 3000;

/*
todo:
- create systemd service
- make some 30s videos and compare performance between this and express
*/

/**
 * Dirt-simple POST request handler that supports one endpoint, firing webhooks.
 *
 * the one webhook
 * When triggered, it kicks off an ffmpeg job to record a live stream and save the file locally.
 * It then calls either the success or error callback.
 * POST /api/v1/webhook
 * body: {
 *     frameRate: string | number, // expected frame rate of stream
 *     length: string | number, // seconds to record, max 15
 *     streamUrl: string | number, // live stream URL
 *     fileName: string, // absolute path, where to save
 *     callback: string, // webhook to call on success
 *     error: string, // webhook to call on failure
 * }
 */
function handlePost(req, reqBody, res) {
    console.log(`received request ${req.url} body: "${reqBody}"`);
    if (req.url.startsWith("/api/v1/webhook/")) {
        const webhookId = req.url.slice(req.url.lastIndexOf("/") + 1);
        console.log(`received webhook ${webhookId}`);
        if (webhookId === "recording") { // todo: get this from argv
            const jsonBody = Json.parse(reqBody);
            const { frameRate, length = 10, streamUrl, fileName, callback, error: errorCb } = jsonBody;
            if (typeof callback !== "string") {
                res.statusCode = 400;
                res.write("missing param: callback (URL)");
            } else {
                const cmd = `ffmpeg -f mjpeg -framerate ${frameRate} -i ${streamUrl} -t ${Math.min(length, 15)} -preset ultrafast -y ${fileName}`;
                console.log(`exec: ${cmd}`);
                exec(cmd, (error, stdOut, stdErr) => {
                    if (error === null || error.code === 0) {
                        console.log(`calling callback "${callback}"`);
                        http.request(callback, { method: "POST" }).end();
                    } else {
                        console.log(`calling error callback ${errorCb}, ${error.code} ${error.name} ${error.message}`);
                        http.request(errorCb, { method: "POST" }).end();
                    }
                });
                res.write("ffmpeg job started");
            }
        }
    } else {
        res.statusCode = 404;
    }
    res.end();
}

function onRequest(req, res) {
    if (req.method === "POST") {
        let reqBody = "";
        req.on("data", (chunk) => reqBody += chunk.toString());
        req.on("end", () => handlePost(req, reqBody, res));
    } else {
        // currently supports posting webhooks and nothing else
        res.statusCode = 405;
        res.end();
    }
}


const httpServer = http.createServer(onRequest);

httpServer.listen(port, hostName, () => {
    console.log(`WH Server (http) running at http://${hostName}:${port}`);
});
