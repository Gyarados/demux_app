// General
const bool USE_MOCK_API_SERVICE = false;
const double DEFAULT_TEXT_SCALE_FACTOR = 1;

// OpenAI
const String OPENAI_API_KEY = "";
const String OPENAI_API_URL = "https://api.openai.com/";
const String OPENAI_CHAT_COMPLETION_ENDPOINT = "/v1/chat/completions";
const String OPENAI_CHAT_COMPLETION_REFERENCE =
    "https://platform.openai.com/docs/api-reference/chat/create";
const List<String> OPENAI_CHAT_COMPLETION_MODEL_LIST = [
  "gpt-4",
  "gpt-4-0613",
  "gpt-4-32k",
  "gpt-4-32k-0613",
  "gpt-3.5-turbo",
  "gpt-3.5-turbo-0613",
  "gpt-3.5-turbo-16k",
  "gpt-3.5-turbo-16k-0613"
];
const String OPENAI_CHAT_COMPLETION_DEFAULT_MODEL = "gpt-3.5-turbo";
const double OPENAI_CHAT_COMPLETION_MIN_TEMPERATURE = 0;
const double OPENAI_CHAT_COMPLETION_MAX_TEMPERATURE = 2;
const double OPENAI_CHAT_COMPLETION_DEFAULT_TEMPERATURE = 0.5;
const String OPENAI_CHAT_COMPLETION_DEFAULT_CHAT_NAME = "New chat";
const String OPENAI_IMAGE_GENERATION_ENDPOINT = "/v1/images/generations";
const String OPENAI_IMAGE_GENERATION_REFERENCE =
    "https://platform.openai.com/docs/api-reference/images/create";
const String OPENAI_IMAGE_EDIT_ENDPOINT = "/v1/images/edits";
const String OPENAI_IMAGE_EDIT_REFERENCE =
    "https://platform.openai.com/docs/api-reference/images/createEdit";
const String OPENAI_IMAGE_VARIATION_ENDPOINT = "/v1/images/variations";
const String OPENAI_IMAGE_VARIATION_REFERENCE =
    "https://platform.openai.com/docs/api-reference/images/createVariation";
const List<String> OPENAI_IMAGE_SIZE_LIST = [
  "256x256",
  "512x512",
  "1024x1024",
];

// Stability AI
const String STABILITY_AI_API_URL = "https://api.stability.ai/";
const String STABILITY_AI_TEXT_TO_IMAGE_ENDPOINT =
    "/v1/generation/{engine_id}/text-to-image";
const String STABILITY_AI_IMAGE_TO_IMAGE_ENDPOINT =
    "/v1/generation/{engine_id}/image-to-image";
const String STABILITY_AI_IMAGE_UPSCALE_ENDPOINT =
    "/v1/generation/{engine_id}/image-to-image/upscale";
const String STABILITY_AI_IMAGE_MASKING_ENDPOINT =
    "/v1/generation/{engine_id}/image-to-image/masking";
const String STABILITY_AI_IMAGE_GENERATION_REFERENCE =
    "https://platform.stability.ai/docs/api-reference#tag/v1generation";
