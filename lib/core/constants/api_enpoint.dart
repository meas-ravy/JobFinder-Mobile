class ApiEnpoint {
  static const String baseUrl = "https://jober-backend-pink.vercel.app/";

  // api enpoint auth
  static const String sentOtp = "api/sent-otp";
  static const String refreshToken = "api/refresh-token";
  static const String verifyOtp = "api/verify-otp";
  static const String resendOtp = "api/resend-otp";
  static const String logout = "api/logout";
  static const String oauth = "api/auth/oauth";
  static const String roleSelect = "api/select-role";
  static const String company = "api/company";
  static const String getUploadSignature = "api/upload/signature";
  static const String jobs = "api/jobs";
  static String submitJob(String jobId) => "api/jobs/$jobId/submit";
  static String updateJobStatus(String jobId) => "api/jobs/$jobId/status";
  static String updateJob(String jobId) => "api/jobs/$jobId";
  static String deleteJob(String jobId) => "api/jobs/$jobId";
  static String jobApplications(String jobId) => "api/jobs/$jobId/applications";
  static const String notifications = "api/notifications";
  static const String markNotificationRead = "api/notifications";
  static const String profile = "api/profile";
  static const String tips = "api/tips";
  static String tipDetail(String tipId) => "api/tips/$tipId";
  static String applyJob(String jobId) => "api/jobs/$jobId/apply";
  static const String categories = "api/jobs/categories";
  static const String myApplications = "api/applications/my-applications";
  static const String recruiterApplications = "api/recruiter/applications";
  static String applicationDetails(String id) => "api/applications/$id";
  static String updateApplicationStatus(String id) =>
      "api/applications/$id/status";
  static const String recruiterDashboard = "api/recruiter/dashboard";
  static const String conversations = "api/conversations";
  static String updateConversation(String id) => "api/conversations/$id";
  static const String firebaseCustomToken = "api/auth/firebase-custom-token";
}
