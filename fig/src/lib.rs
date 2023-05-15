//! fig/src/lib.rs --- Configuration types
use serde::{Serialize, Deserialize};
use obj::Objective;
use std::collections::HashMap as M;
use std::path::PathBuf;
use std::string::String as S;
use std::error::Error as E;
use std::boxed::Box as B;
type R<X> = std::result::Result<X,B<dyn E>>;

/// common trait for all config modules. This trait provides functions
/// for de/serializing to/from RON, updating fields, and formatting.
pub trait Configure: Objective {
  fn update(&self) -> R<()> {
    Ok(())
  }
}

#[derive(Serialize, Deserialize, Debug, Default)]
pub struct ShellConfig {
  pub env: M<S,S>,
  pub cmds: M<S,S>,
  pub shell: ShellType,
}
impl Objective for ShellConfig {}

#[derive(Serialize, Deserialize, Debug, Hash, Default)]
pub enum ShellType {
  #[default]
  Bash,
  Zsh,
  Sh,
}

#[derive(Serialize, Deserialize, Debug, Default)]
pub enum EditorType {
  #[default]
  Emacs,
  Vi,
  Nano,
}

#[derive(Serialize, Deserialize, Debug, Default)]
pub struct EditorConfig {
  pub editor: EditorType,
  pub cmds: M<S,S>,
  pub init_file: PathBuf,
}

#[cfg(test)]
mod tests;
