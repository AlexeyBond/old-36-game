import beads.*;
import org.jaudiolibs.beads.*;

AudioContext ac;
ShortFrameSegmenter sfs;
PowerSpectrum ps;

void setupSound() {
      ac = new AudioContext(new AudioServerIO.JavaSound(),1024,AudioContext.defaultAudioFormat(2,2));

    //UGen microphoneIn = ac.getAudioInput();
    //Gain g = new Gain(ac, 1, 0.5f);
    //g.addInput(microphoneIn);
    
    //Compressor comp = new Compressor(ac).setThreshold(.2).setKnee(.1);
    
    //comp.addInput(g);
    
    //CombFilter comb = new CombFilter(ac, (int)ac.msToSamples(1000));
    
    //comb.setParams(
    //  (int)ac.msToSamples(500),
    //  1.0, .0, .5);
    //comb.addInput(comp);
    
    //ac.out.addInput(comb);

    //println("no. of inputs:  " + ac.getAudioInput().getOuts()); 

    //test get some FFT power spectrum data form the 
    //sfs = new ShortFrameSegmenter(ac);
    //sfs.addInput(ac.out);
    //FFT fft = new FFT();
    //sfs.addListener(fft);
    //ps = new PowerSpectrum();
    //fft.addListener(ps);
    //ac.out.addDependent(sfs);
    
    Sample sample = SampleManager.sample(location + "0xB-00.mp3");
    SamplePlayer splayer = new SamplePlayer(ac, sample);
    splayer.setKillOnEnd(false);
    splayer.setLoopStart(new Static(ac, 0));
    splayer.setLoopEnd(new Static(ac, (float)sample.getLength()));
    splayer.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

    ac.out.addInput(splayer);
    ac.start();
}

void getAudioNoise(float[] out) {
  if (null == ac) return;
  int bsz = ac.getBufferSize();
  for (int i = 0; i < out.length && i*4 < bsz; ++i)
    out[(out.length-1)-i] = ac.out.getValue(0, i*4);
}