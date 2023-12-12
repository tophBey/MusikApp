import 'package:get/get.dart';
import 'package:music_app/controller/song_play_control.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class SongDataCtrl extends GetxController {
  SongPlayCntrl songPlayCntrl = Get.put(SongPlayCntrl());
  final audioQuery = OnAudioQuery();

  RxList<SongModel> localSongList = <SongModel>[].obs;
  RxBool isDeviceSong = false.obs;
  RxInt currentSongPlayIndex = 0.obs;

  @override
  void onInit() {
    //TODO: implemenet onInit
    super.onInit();
    storagePermission();
  }

  void getLocalSongs() async {
    localSongList.value = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );
  }

  void storagePermission() async {
    try {
      var perm = await Permission.storage.request();

      if (perm.isGranted) {
        print('Permission granted');
        getLocalSongs();
      } else {
        print('Permission denied');
        await Permission.storage.request();
      }
    } catch (ex) {
      print(ex);
    }
  }

  void findCurrentSongPlayingIndex(int songId) {
    var index = 0;
    localSongList.forEach((e) {
      if (e.id == songId) {
        currentSongPlayIndex.value = index;
      }
      index++;
    });
    print(songId);
    print(currentSongPlayIndex);
  }

  void playNextSong() {
    int songListLen = localSongList.length;
    currentSongPlayIndex.value = currentSongPlayIndex.value + 1;
    print('Current Index: ${currentSongPlayIndex.value}');

    if (currentSongPlayIndex.value < songListLen) {
      SongModel nextSong = localSongList[currentSongPlayIndex.value];
      songPlayCntrl.playLocalAudio(nextSong);
    }
  }

  void playPreviousSong() {
    int songListLen = localSongList.length;
    print(currentSongPlayIndex.value);

    if (currentSongPlayIndex.value != 0) {
      currentSongPlayIndex.value = --currentSongPlayIndex.value;

      if (currentSongPlayIndex.value < songListLen) {
        SongModel nextSong = localSongList[currentSongPlayIndex.value];
        songPlayCntrl.playLocalAudio(nextSong);
      }
    }
  }
}
