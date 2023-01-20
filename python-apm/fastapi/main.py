from fastapi import FastAPI

app = FastAPI()


from sqlalchemy import create_engine
engine = create_engine('sqlite:///:memory:', echo=True)

from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()

from sqlalchemy import Column, Integer, String

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(64))
    fullname = Column(String(64))
    password = Column(String(64))

    def __init__(self, name, fullname, password):
        self.name = name
        self.fullname = fullname
        self.password = password

    def __repr__(self):
        return "<User('%s', '%s', '%s')>" % (self.name, self.fullname, self.password)

    def as_dict(self):
       return {c.name: getattr(self, c.name) for c in self.__table__.columns}

Base.metadata.create_all(engine)
from sqlalchemy.orm import relationship, joinedload, subqueryload


import random, json, datetime, decimal

def alchemyencoder(obj):

    """JSON encoder function for SQLAlchemy special classes."""

    if isinstance(obj, datetime.date):

        return obj.isoformat()

    elif isinstance(obj, decimal.Decimal):

        return float(obj)
    else:
        return obj.as_dict()
import requests

from sqlalchemy.orm import sessionmaker

Session = sessionmaker(bind=engine)


@app.get("/")
def root_sync(is_exception=False):
    sess = Session()
    import names
    for i in range(random.randrange(100)):
        fullname = names.get_full_name()
    user = User(name=fullname.split()[0], fullname=fullname, password="1234")
    sess.add_all([
        user
    ])
    sess.commit()

    print("is_exception:", is_exception)
    if is_exception=='true':
        raise Exception("root sync exception")
    requests.get('https://www.whatap.io')


    resp=  json.dumps(user, default=alchemyencoder)
    sess.close()
    return resp


@app.get("/async")
async def root_async(is_exception=False):
    sess = Session()
    import names
    for i in range(random.randrange(100)):
        fullname = names.get_full_name()
    user = User(name=fullname.split()[0], fullname=fullname, password="1234")
    sess.add_all([
        user
    ])
    sess.commit()
    if is_exception=='true':
        raise Exception("root sync exception")
    r = requests.get('https://www.whatap.io')
    print(r.text)

    resp=  json.dumps(user, default=alchemyencoder)
    sess.close()
    return resp