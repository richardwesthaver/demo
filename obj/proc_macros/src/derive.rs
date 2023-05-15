mod derive;
use proc_macro::TokenStream;
pub fn derive_static_type(input: TokenStream) -> TokenStream {
    derive::derive_static_type(input)
}
