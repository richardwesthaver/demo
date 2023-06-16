use sqlx::postgres::{PgPool, PgPoolOptions};
use tokio::net::TcpListener;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() {
  tracing_subscriber::registry()
    .with(
      tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| "demo_service=debug".into()),
    )
    .with(tracing_subscriber::fmt::layer())
    .init();

  let listener = TcpListener::bind("127.0.0.1:8888").await.unwrap();
  tracing::debug!("listening on {}", listener.local_addr().unwrap());
}
