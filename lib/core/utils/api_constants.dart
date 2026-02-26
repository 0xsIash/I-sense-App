class ApiConstants {
  static const String baseUrl = "https://founder-involve-down-qualities.trycloudflare.com"; 
  
  static const String loginEndpoint = "/auth/login";
  static const String signupEndpoint = "/auth/signup";
  static const String uploadImageEndpoint = "/images/upload-image";

  static String getJobStatusEndpoint(int jobId) => "/jobs/$jobId"; 
  static String getImageObjectsEndpoint(int imageId) => "/images/$imageId/objects";
  static String deleteImageEndpoint(int imageId) => "/images/$imageId";
  static String getAllImagesEndpoint = "/images";
}