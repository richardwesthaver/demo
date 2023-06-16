use crate::hash::{B3Hasher, KEY_LEN, OUT_LEN};
use rand::Rng;
use serde::{Deserialize, Serialize};
use std::{fmt, str::FromStr};
pub use ulid::Ulid;
pub use uuid::Uuid;
/// a simple Id abstraction
#[derive(Clone, Eq, PartialEq, Ord, PartialOrd, Debug, Serialize, Deserialize, Hash)]
pub struct Id(pub Vec<u8>);

impl Id {
  pub fn rand() -> Self {
    let mut rng = rand::thread_rng();
    let vals: Vec<u8> = (0..KEY_LEN).map(|_| rng.gen_range(0..u8::MAX)).collect();
    Id(vals)
  }

  pub fn state_hash(&self, state: &mut B3Hasher) -> Self {
    let mut output = vec![0; OUT_LEN];
    state.update(&self.0);
    let mut res = state.finalize_xof();
    res.fill(&mut output);
    Id(output)
  }

  pub fn to_hex(&self) -> String {
    hex::encode(&self.0)
  }
}

/// PeerId
///
/// identifies a unique Peer
#[derive(Clone, Eq, Hash, Ord, PartialEq, PartialOrd, Debug)]
pub struct PeerId {
  id: [u8; 32],
}

impl PeerId {
  pub fn new() -> Self {
    Self::default()
  }

  pub fn rand() -> Self {
    let pd = rand::thread_rng().gen::<[u8; 32]>();
    Self { id: pd }
  }

  pub fn from_bytes(data: &[u8]) -> Self {
    let pd = blake3::hash(data);
    let hash = pd.as_bytes();
    Self { id: *hash }
  }
}

impl Default for PeerId {
  fn default() -> Self {
    PeerId { id: [0; 32] }
  }
}

/// Identity trait
///
/// Defines Identity-related behaviors
pub trait Identity: Sized {
  /// return the hashed bytes of an ObjectId
  fn id(&self) -> Id;
}

#[derive(Debug, Copy, Clone, Eq, PartialEq)]
pub struct ObjectId(u128);

pub struct NameSpace {
  pub prefix: Option<String>,
  pub capacity: u64,
  pub route: Vec<Id>,
  pub key: Option<Id>,
}

pub struct Domain {
  pub ns: NameSpace,
  pub id: Id,
}

impl From<Uuid> for ObjectId {
  fn from(uuid: Uuid) -> Self {
    ObjectId(uuid.as_u128())
  }
}

impl From<Ulid> for ObjectId {
  fn from(ulid: Ulid) -> Self {
    ObjectId(u128::from(ulid))
  }
}

impl From<u128> for ObjectId {
  fn from(src: u128) -> Self {
    ObjectId(src)
  }
}

impl FromStr for ObjectId {
  type Err = ();
  fn from_str(input: &str) -> std::result::Result<ObjectId, Self::Err> {
    match input {
      i => Ok(ObjectId(u128::from(Ulid::from_str(i).unwrap()))),
    }
  }
}

impl fmt::Display for ObjectId {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    match *self {
      ObjectId(i) => {
        write!(f, "{}", Ulid::from(i))
      }
    }
  }
}
