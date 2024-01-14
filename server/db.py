from pymongo import MongoClient
from passlib.hash import pbkdf2_sha256

class MongoDB:
    def __init__(self, uri):
        self.client = MongoClient(uri)
        self.db = self.client.cloudbelly  # Replace with your database name

    def get_collection(self, collection_name):
        return self.db[collection_name]

    def create_user(self, email, password, phone, user_type):
        hashed_password = pbkdf2_sha256.hash(password)
        user_data = {
            "email": email,
            "password": hashed_password,
            "phone": phone,
            "user_type": user_type
        }
        users_collection = self.get_collection('users')
        users_collection.insert_one(user_data)

    def validate_login(self, email, password):
        users_collection = self.get_collection('users')
        user = users_collection.find_one({"email": email})
        if user and pbkdf2_sha256.verify(password, user['password']):
            return True
        return False
    
    
    
    
   

mongo_db = MongoDB("mongodb+srv://aniket:S4$PLH9kCuWwLxf@cluster0.cblrxd2.mongodb.net/")