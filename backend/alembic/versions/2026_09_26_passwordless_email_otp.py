"""Add passwordless email OTP and user authentication fields

Revision ID: 2026_09_26_otp
Revises: None
Create Date: 2026-09-26 21:50:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '2026_09_26_otp'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # 1. Add passwordless auth fields to users table
    with op.batch_alter_table('users') as batch_op:
        batch_op.add_column(sa.Column('email_verified', sa.Boolean(), nullable=False, server_default='0'))
        batch_op.add_column(sa.Column('authentication_provider', sa.String(length=50), nullable=False, server_default='email_otp'))
        batch_op.add_column(sa.Column('last_login_at', sa.DateTime(), nullable=True))
        batch_op.add_column(sa.Column('is_onboarded', sa.Boolean(), nullable=False, server_default='0'))
        batch_op.alter_column('hashed_password', nullable=True)
        batch_op.alter_column('full_name', nullable=True)
        batch_op.alter_column('phone', nullable=True)

    # 2. Create email_otp_codes table
    op.create_table(
        'email_otp_codes',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('otp_hash', sa.String(length=255), nullable=False),
        sa.Column('expires_at', sa.DateTime(), nullable=False),
        sa.Column('attempts', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('verified_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('request_ip', sa.String(length=100), nullable=True),
        sa.Column('consumed', sa.Boolean(), nullable=False, server_default='0'),
    )
    op.create_index('ix_email_otp_codes_email', 'email_otp_codes', ['email'])
    op.create_index('ix_email_otp_codes_expires_at', 'email_otp_codes', ['expires_at'])
    op.create_index('ix_email_otp_codes_created_at', 'email_otp_codes', ['created_at'])


def downgrade():
    op.drop_index('ix_email_otp_codes_created_at', table_name='email_otp_codes')
    op.drop_index('ix_email_otp_codes_expires_at', table_name='email_otp_codes')
    op.drop_index('ix_email_otp_codes_email', table_name='email_otp_codes')
    op.drop_table('email_otp_codes')

    with op.batch_alter_table('users') as batch_op:
        batch_op.drop_column('is_onboarded')
        batch_op.drop_column('last_login_at')
        batch_op.drop_column('authentication_provider')
        batch_op.drop_column('email_verified')
