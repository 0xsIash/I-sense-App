class ApiConstants {
  static const String baseUrl = "https://involvement-promotional-msgid-zoloft.trycloudflare.com"; 
  
  static const String loginEndpoint = "/auth/login";
  static const String signupEndpoint = "/auth/signup";
  static const String uploadImageEndpoint = "/images/upload-image";

  static String getJobStatusEndpoint(int jobId) => "/jobs/$jobId"; 
  static String getImageObjectsEndpoint(int imageId) => "/images/$imageId/objects";
  static String deleteImageEndpoint(int imageId) => "/images/$imageId";
  static String getAllImagesEndpoint = "/images";
  static String getSimilrProductsEndpoint(int imageId, int objId) => "/similar_products/$imageId/$objId/similar-products";

  static String getPublishedImages = "/share/feed";
  static String publishImage(int imageId) => "/share/$imageId/publish";
  static String unpublishImage(int imageId) => "/share/$imageId/unpublish";   

  static String getSimilarItemsEndpoint(int imageId, int objId) => "/similar_products/$imageId/$objId/similar-products";
  
}