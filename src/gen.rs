//! demo
pub use fig::*;
pub use obj::*;
use std::ffi::{CStr, CString}; //OsStr,Path
                               //use std::os::unix::ffi::OsStrExt;
use std::slice;
use libc::{c_char,size_t};

#[macro_export]
macro_rules! cdefn {
  (free $t:tt $n:tt) => {
    #[no_mangle]
    pub unsafe extern "C" fn $n(ptr: *mut $t) {
      if ptr.is_null() {
        return;
      }
      let _ = Box::from_raw(ptr);
    }
  };
  (from_string $t:tt $n:tt) => {
    #[no_mangle]
    pub unsafe extern "C" fn $n(ptr: *const c_char) -> *mut $t {
      assert!(!ptr.is_null());
      let p = CStr::from_ptr(ptr).to_str().unwrap();
      Box::into_raw(Box::new(p.into()))
    }
  };
  (json_string $t:tt $r:tt $w:tt) => {
    #[no_mangle]
    pub unsafe extern "C" fn $r(ptr: *const c_char) -> *mut $t {
      assert!(!ptr.is_null());
      let s = CStr::from_ptr(ptr);
      Box::into_raw(Box::new($t::from_json_str(&s.to_str().unwrap()).unwrap()))
    }

    #[no_mangle]
    pub unsafe extern "C" fn $w(ptr: *const $t) -> *mut c_char {
      let p = &*ptr;
      let x = p.to_json_string().unwrap();
      CString::new(x.as_str().as_bytes()).unwrap().into_raw()
    }
  };
  (ron_string $t:tt $r:tt $w:tt) => {
    #[no_mangle]
    pub unsafe extern "C" fn $r(ptr: *const c_char) -> *mut $t {
      assert!(!ptr.is_null());
      let s = CStr::from_ptr(ptr);
      Box::into_raw(Box::new($t::from_ron_str(&s.to_str().unwrap()).unwrap()))
    }

    #[no_mangle]
    pub unsafe extern "C" fn $w(ptr: *const $t) -> *mut c_char {
      let p = &*ptr;
      let x = p.to_ron_string().unwrap();
      CString::new(x.as_str().as_bytes()).unwrap().into_raw()
    }
  };
  (bytes $t:tt $r:tt $w:tt) => {
    #[no_mangle]
    pub unsafe extern "C" fn $r(ptr: *const u8, len: size_t) -> *mut $t {
      Box::into_raw(Box::new($t::decode(slice::from_raw_parts(ptr,len)).unwrap()))
    }

    #[no_mangle]
    pub unsafe extern "C" fn $w(ptr: *const $t) -> *mut u8 {
      let p = &*ptr;
      let mut x = p.encode().unwrap();
      let r = x.as_mut_ptr();
      std::mem::forget(x);
      r
    }
  }
}

cdefn!(free Service free_service);
cdefn!(from_string Service service_from_string);
cdefn!(json_string Service service_from_json_string service_to_json_string);
cdefn!(ron_string Service service_from_ron_string service_to_ron_string);
cdefn!(bytes Service service_decode service_encode);
cdefn!(free CustomService free_custom_service);
cdefn!(from_string CustomService custom_service_from_string);
cdefn!(json_string CustomService custom_service_from_json_string custom_service_to_json_string);
cdefn!(ron_string CustomService custom_service_from_ron_string custom_service_to_ron_string);
cdefn!(bytes CustomService custom_service_decode custom_service_encode);
