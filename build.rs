use std::env;
use std::fs::create_dir;
use std::path::PathBuf;
fn main() {
  let crate_dir: PathBuf = env::var("CARGO_MANIFEST_DIR")
    .expect("CARGO_MANIFEST_DIR env var is not defined")
    .into();
  // let mpk_py = "build.py";
  let build_dir = crate_dir.join("ffi/");
  if !build_dir.exists() {
    create_dir(&build_dir).unwrap();
  }
  cbindgen::generate(crate_dir)
    .expect("Unable to find cbindgen.toml configuration file")
    .write_to_file(build_dir.join("demo.h"));
}
