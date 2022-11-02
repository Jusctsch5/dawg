import 'package:dawg/workout/announcer.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';


Future<void> testAnnouncer() async {
  var announcer = AnnouncerTts();

  await announcer.announce("hello world wii");
  for (int i = 1; i <= 3; i++) {
    await announcer.announce("hello world $i");
  }

  await announcer.announce("test delay 2 seconds");
  await announcer.announceDelay(2);
  await announcer.announce("delay done");

  await announcer.announce("test countdown from 5");
  await announcer.announceCountdown(5);
  await announcer.announce("countdown done");

}

void main() {
  group("Announcer", () {
    test("testAnnouncer", () async {
      WidgetsFlutterBinding.ensureInitialized();
      await testAnnouncer();
    });
  });
}
