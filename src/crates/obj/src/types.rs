//! obj/src/types.rs --- OBJ type descriptions used by our demo
use crate::{Deserialize, Objective, Result, Serialize};
use std::collections::HashMap;

/// APPLICATION TYPES
#[derive(Serialize,Deserialize,Default)]
pub enum Service {
  Weather,
  Stocks,
  Dynamic(Vec<Service>),
  Custom(CustomService),
  #[default]
  Bench,
}

impl Objective for Service {}

impl From<&str> for Service {
  fn from(value: &str) -> Self {
    match value {
      "weather" => Service::Weather,
      "stocks" => Service::Stocks,
      "bench" => Service::Bench,
      s => {
        if s.contains(",") {
          let x = s.split(",");
          Service::Dynamic(
            x.map(|y| Service::Custom(y.into()))
              .collect::<Vec<Service>>(),
          )
        } else {
          Service::Custom(s.into())
        }
      }
    }
  }
}

#[derive(Serialize,Deserialize,Default)]
pub struct CustomService {
  name: String,
  registry: HashMap<String,Vec<u8>>,
}

impl Objective for CustomService {}
impl From<CustomService> for Service {
  fn from(value: CustomService) -> Self {
    Service::Custom(value)
  }
}
impl From<&str> for CustomService {
  fn from(value: &str) -> Self {
    let name = value.to_owned();
    let registry = HashMap::new();
    CustomService { name, registry }
  }
}

#[derive(Serialize, Deserialize,Default)]
pub struct Complex<X: Objective> {
  data: X,
  stack: Vec<u8>,
  registry: HashMap<String,Vec<u8>>,
}

impl Objective for Complex<Service> {}

pub fn generate_complex() -> Result<Complex<Service>> {
  Ok(Complex::<Service>::from_json_str("hi")?)
}
