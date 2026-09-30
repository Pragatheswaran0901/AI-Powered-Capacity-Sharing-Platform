from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings

# Configure connect_args based on SQLite vs Postgres
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args["check_same_thread"] = False

engine = create_engine(
    settings.DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def run_migrations(target_engine=None):
    from sqlalchemy import inspect, text
    eng = target_engine or engine
    try:
        with eng.connect() as conn:
            inspector = inspect(eng)
            if "users" in inspector.get_table_names():
                columns = [c["name"] for c in inspector.get_columns("users")]
                if "email_verified" not in columns:
                    conn.execute(text("ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT 1 NOT NULL"))
                if "authentication_provider" not in columns:
                    conn.execute(text("ALTER TABLE users ADD COLUMN authentication_provider VARCHAR(50) DEFAULT 'email_otp' NOT NULL"))
                if "last_login_at" not in columns:
                    conn.execute(text("ALTER TABLE users ADD COLUMN last_login_at TIMESTAMP"))
                if "is_onboarded" not in columns:
                    conn.execute(text("ALTER TABLE users ADD COLUMN is_onboarded BOOLEAN DEFAULT 1 NOT NULL"))
                conn.commit()

            if "machines" in inspector.get_table_names():
                m_columns = [c["name"] for c in inspector.get_columns("machines")]
                if "company_id" not in m_columns:
                    conn.execute(text("ALTER TABLE machines ADD COLUMN company_id VARCHAR(50)"))
                if "google_maps_link" not in m_columns:
                    conn.execute(text("ALTER TABLE machines ADD COLUMN google_maps_link VARCHAR(500)"))
                conn.commit()
    except Exception as e:
        pass
