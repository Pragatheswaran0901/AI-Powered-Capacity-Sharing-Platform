from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class NotificationOut(BaseModel):
    id: str
    user_id: str
    title: str
    message: str
    event_type: str
    reference_id: Optional[str] = None
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
