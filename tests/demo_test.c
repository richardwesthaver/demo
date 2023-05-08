#include <stdio.h>
#include "demo.h"

int main() {
  Service *srv = service_from_string("weather");
  printf!("%s\n",service_to_json_str(srv));
  free_service(srv);
}
