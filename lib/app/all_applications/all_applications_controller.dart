import 'package:agro/app/home/components/home_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllApplicationsController extends HomeController {
  
  final RefreshController allApplicationsRefreshController = RefreshController();

  @override
  void onInit() {
    super.onInit();
    allApplicationsRefreshController;
  } 
  void refreshAllApplications() { 
    allApplicationsRefreshController.requestRefresh(); 
  }

  @override
  void dispose() {
    allApplicationsRefreshController.dispose();
    super.dispose();
  }
}