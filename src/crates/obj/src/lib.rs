//! obj/src/lib.rs --- Objective type library
#![feature(associated_type_bounds)]
mod err;
pub use err::{Error, Result};
mod types;
pub use types::*;
pub mod auth;
pub mod database;
pub mod hash;
pub mod id;
pub mod network;
pub use bincode;
pub use ron;
use ron::extensions::Extensions;
use serde::{de::DeserializeOwned, Deserialize, Serialize};
pub use serde_json;
use std::collections::{BTreeMap, HashMap};
use std::io;

/// Objective trait
/// Define Object behaviors, implemented by Objects
pub trait Objective {
  fn encode(&self) -> Result<Vec<u8>>
  where
    Self: Serialize,
  {
    Ok(bincode::serialize(self)?)
  }

  fn encode_into<W>(&self, writer: W) -> Result<()>
  where
    W: io::Write,
    Self: Serialize,
  {
    Ok(bincode::serialize_into(writer, self)?)
  }

  fn decode<'a>(bytes: &'a [u8]) -> Result<Self>
  where
    Self: Deserialize<'a>,
  {
    Ok(bincode::deserialize(bytes)?)
  }

  fn decode_from<R>(&self, rdr: R) -> Result<Self>
  where
    R: io::Read,
    Self: DeserializeOwned,
  {
    Ok(bincode::deserialize_from(rdr)?)
  }

  fn to_ron_writer<W>(&self, writer: W) -> Result<()>
  where
    W: io::Write,
    Self: Serialize,
  {
    Ok(ron::ser::to_writer_pretty(
      writer,
      &self,
      ron::ser::PrettyConfig::new()
        .indentor("  ".to_owned())
        .extensions(Extensions::all()),
    )?)
  }

  fn to_ron_string(&self) -> Result<String>
  where
    Self: Serialize,
  {
    Ok(ron::ser::to_string_pretty(
      &self,
      ron::ser::PrettyConfig::new().indentor("  ".to_owned()),
    )?)
  }

  fn from_ron_reader<R>(&self, mut rdr: R) -> Result<Self>
  where
    R: io::Read,
    Self: DeserializeOwned,
  {
    let mut bytes = Vec::new();
    rdr.read_to_end(&mut bytes)?;
    Ok(ron::de::from_bytes(&bytes)?)
  }

  fn from_ron_str<'a>(s: &'a str) -> Result<Self>
  where
    Self: Deserialize<'a>,
  {
    Ok(ron::de::from_bytes(s.as_bytes())?)
  }

  fn to_json_writer<W>(&self, writer: W) -> Result<()>
  where
    W: io::Write,
    Self: Serialize,
  {
    //    let formatter = serde_json::ser::PrettyFormatter::with_indent(b"  ");
    Ok(serde_json::ser::to_writer_pretty(writer, &self)?)
  }

  fn to_json_string(&self) -> Result<String>
  where
    Self: Serialize,
  {
    Ok(serde_json::ser::to_string_pretty(&self)?)
  }

  fn from_json_reader<R>(&self, mut rdr: R) -> Result<Self>
  where
    R: io::Read,
    Self: DeserializeOwned,
  {
    let mut bytes = Vec::new();
    rdr.read_to_end(&mut bytes)?;
    Ok(serde_json::de::from_slice(&bytes)?)
  }

  fn from_json_str<'a>(s: &'a str) -> Result<Self>
  where
    Self: Deserialize<'a>,
  {
    Ok(serde_json::de::from_slice(s.as_bytes())?)
  }
}

impl<T> Objective for Vec<T> {}
impl<K, V> Objective for HashMap<K, V> {}
impl<K, V> Objective for BTreeMap<K, V> {}
impl Objective for std::path::PathBuf {}
impl Objective for std::path::Path {}
impl Objective for std::string::String {}
impl Objective for std::any::TypeId {}
impl Objective for u8 {}
impl Objective for u16 {}
impl Objective for u32 {}
impl Objective for u64 {}
impl Objective for u128 {}
impl Objective for i8 {}
impl Objective for i16 {}
impl Objective for i32 {}
impl Objective for i64 {}
impl Objective for i128 {}
impl Objective for isize {}
impl Objective for usize {}
impl Objective for f32 {}
impl Objective for f64 {}
