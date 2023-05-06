//! obj/src/types.rs --- OBJ type descriptions used by our demo
use crate::{Error, Result, Objective, Serialize, Deserialize};
/// APPLICATION TYPES
#[derive(Serialize, Deserialize)]
pub enum Service {
  Nws,
  Fin,
  Pvp,
}

impl Objective for Service {}

#[derive(Serialize, Deserialize)]
pub struct Complex<X: Objective> {
  data: X,
  state: Vec<u8>,
}

impl Objective for Complex<Service> {}

pub fn generate_complex() -> Result<Complex<Service>> {
  Ok(Complex::<Service>::from_json_str("hi")?)
}
