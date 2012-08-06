#ifndef _FLVENCODER_H_
#define _FLVENCODER_H_
#include <pthread.h>
#include "video.h"
#include "audio.h"
#include "codecs.h"
#include "rtmpstream.h"

class FLVEncoder : public RTMPMediaStream
{
public:
	FLVEncoder();
	~FLVEncoder();

	int Init(AudioInput* audioInput,VideoInput *videoInput);
	int StartEncoding();
	int StopEncoding();
	int End();
	/* Overrride from RTMPMediaStream*/
	virtual DWORD AddMediaListener(RTMPMediaStream::Listener *listener);
protected:
	int EncodeAudio();
	int EncodeVideo();

private:
	//Funciones propias
	static void *startEncodingAudio(void *par);
	static void *startEncodingVideo(void *par);
	
private:
	AudioCodec::Type	audioCodec;
	AudioInput*		audioInput;
	pthread_t		encodingAudioThread;
	int			encodingAudio;

	VideoInput*		videoInput;
	pthread_t		encodingVideoThread;
	int			encodingVideo;

	int		inited;
	bool		sendFPU;
	timeval		ini;
	pthread_mutex_t mutex;
};

#endif
