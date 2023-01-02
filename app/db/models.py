from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from .database import Base


class time(Base):
    __tablename__ = "users"

    time = Column(Integer, primary_key=True, index=True)