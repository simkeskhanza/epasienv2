import 'package:ALPOKAT/app/data/MLBookAppointmentData.dart';
import 'package:ALPOKAT/app/modules/halaman_booking/components/MLBookedDailog.dart';
import 'package:ALPOKAT/app/modules/halaman_booking/models/jadwal_poliklinik_model.dart';
import 'package:ALPOKAT/app/modules/halaman_booking/models/penjab_model.dart';
import 'package:ALPOKAT/app/modules/halaman_booking/providers/booking_provider.dart';
import 'package:ALPOKAT/app/utils/MLDataProvider.dart';
import 'package:ALPOKAT/app/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HalamanBookingController extends GetxController {
  //TODO: Implement HalamanBookingController
  BookingProvider _bookingProvider = GetInstance().put(BookingProvider());
  final pasien = GetStorage().read('pasien');
  var currentWidget = 0.obs;
  var selectedIndex = 0.obs;
  var selectedKdPoli = "".obs;
  var selectedPoli = "".obs;
  var selectedKdDokter = "".obs;
  var selectedDokter = "".obs;
  var selectedIndexPenjab = 0.obs;
  var selectedKdPenjab = "".obs;
  var selectedPenjab = "".obs;
  var selectedJam = "".obs;
  List<MLBookAppointmentData> data = mlBookAppointmentDataList();
  var listPoliklinik = <JadwalPoliklinikModel>[].obs;
  var listPenjab = <PenjabModel>[].obs;
  var selectedDate = DateTime.now().add(Duration(days: 1)).obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    // cekBookingReg();
    getPoliklinik();
    // getPenjab();
    super.onReady();
  }

  @override
  void onClose() {}

  getPoliklinik() {
    try {
      isLoading(true);
      Future.delayed(
        Duration(seconds: 1),
        () {
          var body = {
            'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value),
          };

          _bookingProvider.fetchJadwalPoliklinik(body).then((value) {
            listPoliklinik.value = value;
            if (listPoliklinik.value.isEmpty) {
              selectedKdDokter.value = "";
              selectedKdPoli.value = "";
            } else {
              selectedKdDokter.value = listPoliklinik.value[0].kdDokter!;
              selectedDokter.value = listPoliklinik.value[0].nmDokter!;
              selectedKdPoli.value = listPoliklinik.value[0].kdPoli!;
              selectedPoli.value = listPoliklinik.value[0].nmPoli!;
              selectedJam.value =
                  '${listPoliklinik.value[0].jamMulai} - ${listPoliklinik.value[0].jamSelesai}';
            }
            isLoading(false);
          });
        },
      );
    } catch (e) {
      print(e);
    }
  }

  getPenjab() {
    try {
      isLoading(true);
      Future.delayed(
        Duration(seconds: 1),
        () {
          _bookingProvider.fetchPenjab().then((value) {
            listPenjab.value = value;
            selectedKdPenjab.value = listPenjab.value[0].kdPj!;
            selectedPenjab.value = listPenjab.value[0].pngJawab!;
            isLoading(false);
          });
        },
      );
    } catch (e) {
      print(e);
    }
  }

  postBooking() {
    try {
      Future.delayed(
        Duration.zero,
        () => DialogHelper.showLoading('Loading.....'),
      );
      var body = {
        'no_rkm_medis': pasien['no_rkm_medis'],
        'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate.value),
        'kd_poli': selectedKdPoli.value,
        'kd_dokter': selectedKdDokter.value,
        'kd_pj': selectedKdPenjab.value
      };
      print(body);
      _bookingProvider.postBooking(body).then((res) {
        DialogHelper.hideLoading();
        if (res.statusCode == 200) {
          Get.dialog(
            MLBookedDialog(
              desc: res.body['message'],
            ),
          );
        } else {
          Get.snackbar(
            'Error',
            res.statusText!,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      });
    } catch (e) {
      print(e);
      DialogHelper.hideLoading();
    }
  }

  // cekBookingReg() {
  //   try {
  //     Future.delayed(
  //       Duration(seconds: 3),
  //     );
  //     var body = {
  //       'no_rkm_medis': '165056',
  //     };
  //     BookingProvider()
  //         .post(
  //             'https://webapps.rsbhayangkaranganjuk.com/api-rsbnganjuk/api/v1/apm/cekbookingreg',
  //             body)
  //         .then((res) {
  //       if (res.statusCode == 200) {
  //         selectedJam.value = res.body['data']['tanggal_periksa'];
  //         selectedDokter.value = res.body['data']['nm_dokter'];
  //         selectedKdPoli.value = res.body['data']['nm_poli'];
  //         selectedPenjab.value = res.body['data']['png_jawab'];
  //         BuildContext context = Get.context!;
  //         MLCheckBookingList().launch(context);
  //       }
  //     });
  //   } catch (e) {}
  // }
}
