#ifndef demo_h
#define demo_h

/* Generated with cbindgen:0.24.3 */

/* DO NOT TOUCH */

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#define KEY_LEN 32

#define OUT_LEN 32

#define OUT_LEN_HEX (OUT_LEN * 2)

typedef struct CustomService CustomService;

/**
 * APPLICATION TYPES
 */
typedef struct Service Service;

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

void free_service(struct Service *ptr);

struct Service *service_from_string(const char *ptr);

struct Service *service_from_json_string(const char *ptr);

char *service_to_json_string(const struct Service *ptr);

struct Service *service_from_ron_string(const char *ptr);

char *service_to_ron_string(const struct Service *ptr);

struct Service *service_decode(const uint8_t *ptr, size_t len);

uint8_t *service_encode(const struct Service *ptr);

void free_custom_service(struct CustomService *ptr);

struct CustomService *custom_service_from_string(const char *ptr);

struct CustomService *custom_service_from_json_string(const char *ptr);

char *custom_service_to_json_string(const struct CustomService *ptr);

struct CustomService *custom_service_from_ron_string(const char *ptr);

char *custom_service_to_ron_string(const struct CustomService *ptr);

struct CustomService *custom_service_decode(const uint8_t *ptr, size_t len);

uint8_t *custom_service_encode(const struct CustomService *ptr);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#endif /* demo_h */
