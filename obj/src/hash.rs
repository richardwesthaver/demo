//! hash - wrapper for hash algorithms and types

pub use blake3::{derive_key, hash, keyed_hash, Hash as B3Hash, Hasher as B3Hasher, OutputReader};
pub use hex;
pub use sha2::Sha512;

pub use std::hash::{Hash, Hasher};

pub const KEY_LEN: usize = 32;
pub const OUT_LEN: usize = 32;
pub const OUT_LEN_HEX: usize = OUT_LEN * 2;

#[cfg(test)]
mod tests {
  use crate::*;
  use super::*;
  #[test]
  fn id_state_hash() {
    let id = id::Id(vec![0; KEY_LEN]);
    let hash = id.state_hash(&mut B3Hasher::new());
    assert_eq!(hash, id.state_hash(&mut B3Hasher::new()));
  }

  #[test]
  fn id_hex() {
    let id = id::Id(vec![255; KEY_LEN]);

    assert_eq!(
      hex::decode("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff").unwrap(),
      id.0
    );
  }

  #[test]
  fn rand_id() {
    let id = id::Id::rand();
    let hash = id.state_hash(&mut B3Hasher::new());
    assert_eq!(hash, id.state_hash(&mut B3Hasher::new()));
  }

  #[test]
  fn random_demon_id_is_valid() {
    use id::PeerId;
    for _ in 0..5000 {
      let did = PeerId::rand();
      let did2 = PeerId::rand();
      assert_eq!(did, did);
      assert_ne!(did, did2);
    }
  }
}
