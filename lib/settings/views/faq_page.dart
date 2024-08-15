import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
      ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text("Q: What's the purpose of this app?\n",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'A: This app syncs your music to your running cadence. For most beginner runners, this is around 150-160bpm, but this will vary depedning on your stride length and your fitness level. This can help you take your mind off the negative aspects of exercise and help you maintain a consistent and easy pace throughout your run. Don\'t knock it till you try it!\n'),
                Text(
                  "Q: Why is my song BPM off?\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    "A: The app uses a third-party beat detection and tempo estimation algorithm to calculate the BPM of your song.\n\nHere are some possible errors that you may encounter:\n\nBPM is off by a factor of 2: this is normal. We normalise the BPM to a range of 120-240BPM. A song at 80BPM will be read in double time, whereas a song at 250BPM will be read at half time. Simply put, it doesn't make sense to adjust the BPM of a song at 80BPM to 160BPM when it was perfectly fine for running as is!\n A consequence of this is that songs in the 100-120BPM range will sound off. There's no workaround for this; songs in this tempo range generally don't sound as good for running. We recommend finding songs outside of this range for your runs.\n\nBPM is off by a strange factor: this is known as an octave error. This is caused when the algorithm picks up off-beats and syncopations as the main beat, leading to an estimation that is completely off. Apologies for the inconvenience, you will have to manually input BPM in this case.\n\nBPM is off by a small amount: we recognise that small changes in tempo do have significant effects on the intensity level of the run. Within 1-3BPM is the most accurate readings that the algorithm can provide. Do note that tempo is also subjective. It seems counterintuitive as BPM is an absolute meaure, but human perception of tempo can vary greatly. For these cases, it may be easier to simply adjust the BPMSync during the workout depending on how you feel. We have designed it to prioritise fine adjustments.\n\nIn any case, if you find that the BPM is off, you can manually adjust it by holding down on the song and inputting the correct BPM.\n"),
                Text("Q: Why does the app request so many permissions?\n",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    "A: These permissions are required to run the app in the background, especially on Android. You can request them again in the settings menu if you disallowed them before."),
              ],
            ),
          ),
        )
    );
  }
}
