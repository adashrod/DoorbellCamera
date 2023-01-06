import subprocess

# The functions in this file are invoked by Home Assistant, using the PyScript plugin
# see https://www.home-assistant.io/docs/
# see https://github.com/custom-components/pyscript

@pyscript_executor
def do_ffmpeg(streamUrl, frameRate, length, fileName):
#    note: log is not in scope in this function
    proc = subprocess.Popen(["ffmpeg",
        "-f", "mjpeg",
        "-framerate", "5", # must match framerate of the video stream
        "-i" , streamUrl,
        "-t", length,
        "-y",
        f"www/videos/{fileName}"])
    # causes the process to block, ensuring that the event fires after the recording finishes
    proc.communicate()

@service
def record_stream_ffmpeg(streamUrl, frameRate, length, fileName):
    """Records the video stream for a specified time, writes the file to "www/videos/latestOnDemandVideo.mp4" and
    fires an event "on_demand_video_ready"
    
    Parameters
    ----------
    streamUrl : str
        URL to the video stream
    frameRate : str
        frame rate of the source video
    length : str
        number of seconds to record
    fileName : str
        name of file to write
    """

    log.info("starting ffmpeg process")
    do_ffmpeg(streamUrl, str(frameRate), str(length), fileName)
    log.info("done recording")
    event.fire("on_demand_video_ready")
