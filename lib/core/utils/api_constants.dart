class ApiConstants {
  static const String baseUrl = "https://qualifying-starting-acquire-pending.trycloudflare.com"; 

  static const String loginEndpoint = "/auth/login";
  static const String signupEndpoint = "/auth/signup";
  static const String uploadImageEndpoint = "/images/upload-image";

  static String getJobStatusEndpoint(int jobId) => "/jobs/$jobId"; 
  static String getImageObjectsEndpoint(int imageId) => "/images/$imageId/objects";
  static String deleteImageEndpoint(int imageId) => "/images/$imageId";
  static const String getAllImagesEndpoint = "/images/"; 

  static const String getPublishedImages = "/share/feed";
  static String publishImage(int imageId) => "/share/$imageId/publish";
  static String unpublishImage(int imageId) => "/share/$imageId/unpublish";

  static const String getMySharedImagesEndpoint = "/share/my-shared";

  static const String profileEndpoint = "/auth/profile";
  static const String updateProfileEndpoint = "/auth/profile/update";
  static const String changePasswordEndpoint = "/auth/password";

  static String getSimilarProductsEndpoint(int imageId, int objId) => "/similar_products/$imageId/$objId/similar-products";
}