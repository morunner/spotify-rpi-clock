from sqlalchemy import create_engine, ForeignKey, Column, String, Integer, CHAR, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

metadata = MetaData()

engine = create_engine("mysql+mysqlconnector://root:tu8435_$@localhost:3306/spotify-rpi-clock_settings", echo=True)

metadata.reflect(bind=engine)
table = metadata.tables['time']

query = table.insert().values(id=12, wakeup_time="05:05:03")

connection = engine.connect()

result = connection.execute("SELECT * FROM time")

for row in result:
    print(row)

connection.close()