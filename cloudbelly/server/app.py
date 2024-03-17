from flask import Flask, render_template, request, redirect, url_for, flash, session,jsonify
from db import mongo_db
from werkzeug.utils import secure_filename
import uuid
from bson.objectid import ObjectId
import os
import pytesseract
from PIL import Image
import requests
from datetime import datetime
app = Flask(__name__,static_folder='static')
app.secret_key = '2345dtgbewr25678'
app.config['UPLOAD_FOLDER'] = os.path.join(app.static_folder, 'uploads')
app.config['ALLOWED_EXTENSIONS'] = {'png', 'jpg', 'jpeg', 'gif'}


def reverse_geocode(latitude, longitude):
    access_key = 'e2a74de4e6c1558dee65c3576a097093'  # Your Positionstack API key
    url = 'http://api.positionstack.com/v1/reverse'
    params = {
        'access_key': access_key,
        'query': f'{latitude},{longitude}',
        'limit': 1,  # Assuming you want just the most relevant result
        'output': 'json'
    }

    response = requests.get(url, params=params)
    data = response.json()

    if 'data' in data and len(data['data']) > 0:
        # Get the first result
        location_data = data['data'][0]
        # Construct a readable address from the components you need
        address = f"{location_data.get('label', 'Unknown Location')}"
        return address
    else:
        return "Unknown Location"

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in app.config['ALLOWED_EXTENSIONS']


@app.route('/upload', methods=['POST'])
def upload_file():
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401  # Unauthorized access

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    if not user:
        return jsonify({'error': 'User not found'}), 404  # User not found

    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400  # Missing file part

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400  # No file selected

    if file and allowed_file(file.filename):
        # Generate a unique ID for the post
        post_id = str(uuid.uuid4())
        # Create a secure filename with the post ID prefixed
        filename = secure_filename(post_id + '_' + file.filename)
        # Create a file path for saving the file
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        # Create a relative path for storing in the database and using in the app
        relative_path = os.path.join('uploads', filename)

        try:
            # Ensure the UPLOAD_FOLDER exists
            os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
            # Save the file
            file.save(file_path)
            # Create a post object with ID and relative path
            latitude = request.form.get('latitude')
            longitude = request.form.get('longitude')
            location = None
            
            if latitude and longitude:
                location = reverse_geocode(latitude, longitude)
                # Here you could use a geocoding service to convert latitude and longitude to a readable address
                # location = f'Latitude: {latitude}, Longitude: {longitude}'

            post = {
                'id': post_id,
                'file_path': relative_path,
                'created_at': datetime.now(),
                'location': location,
                'likes': [],  # Initialize likes 
                'comments': []  # Initialize comments list
            }

            # Update the user's document in MongoDB with the post object
            mongo_db.get_collection('users').update_one(
                {'_id': user['_id']}, 
                {'$push': {'posts': post}}
            )
            return jsonify({'message': 'File successfully uploaded and post published', 'post_id': post_id}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        return jsonify({'error': 'Invalid file type'}), 400  # Invalid file type
    
def save_file(user_id, file_path):
    # Save the file path to the user's document in MongoDB
    users_collection = mongo_db.get_collection('users')
    users_collection.update_one({'_id': user_id}, {'$set': {'content_path': file_path}})
    return {"code":200,"msg":"File Uploaded Successfully"}

def get_user_id(email):
        user = mongo_db.get_collection('users').find_one({'email': email})
        return str(user['_id']) if user else None

@app.route('/')
def default():
    return render_template('signup.html')

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    try:
        session.pop('email', None)
    except:
        print("session does not exist")
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        phone = request.form.get('phone')
        user_type = request.form.get('user_type')

        if mongo_db.get_collection('users').find_one({'email': email}):
            flash('User already exists', 'danger')
            return render_template('signup.html')

        mongo_db.create_user(email, password, phone, user_type)
        flash('Registration successful, please login', 'success')
        return redirect(url_for('login'))

    return render_template('signup.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'email' in session:
        # Fetch the user from the database to get the user_id
        user_email = session['email']
        user = mongo_db.get_collection('users').find_one({'email': user_email})
        if user:
            print(user)
            if user['user_type'] == "customer":
                    return redirect(url_for('profile', user_id=str(user['_id'])))
            else:
                return redirect(url_for('vendor_home', user_id=str(user['_id'])))
            
        else:
            # If the user somehow does not exist in the database, clear the session
            session.pop('email', None)
            flash('User not found. Please login again.', 'warning')
            return redirect(url_for('login'))

    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        if mongo_db.validate_login(email, password):
            session['email'] = email
            # Fetch the user again to get the user_id for redirection
            user = mongo_db.get_collection('users').find_one({'email': email})
            if user:
                print(user)
                if user['user_type'] == "customer":
                    return redirect(url_for('profile', user_id=str(user['_id'])))
                else:
                    return redirect(url_for('vendor_home', user_id=str(user['_id'])))
            else:
                flash('User not found. Please try again.', 'danger')
        else:
            flash('Invalid credentials', 'danger')

    return render_template('login.html')


@app.route('/success')
def success():
    if 'email' not in session:
        return redirect(url_for('login'))

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    if not user:
        # Handle the case where the user isn't found
        flash('User not found.')
        return redirect(url_for('login'))

    # Now that you have the user, pass the user_id to the template
    return render_template('success.html', email=session['email'], user_id=str(user['_id']))


@app.route('/update_profile_photo', methods=['POST'])
def update_profile_photo():
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        # Save the file inside the static/uploads directory
        file_path = os.path.join('uploads', filename)  # Relative path
        full_path = os.path.join(app.static_folder, file_path)  # Full path

        try:
            # Ensure the uploads directory exists inside the static folder
            os.makedirs(os.path.join(app.static_folder, 'uploads'), exist_ok=True)
            # Save the file
            file.save(full_path)
            # Update the user's profile photo in MongoDB with the relative path
            mongo_db.get_collection('users').update_one({'_id': user['_id']}, {'$set': {'profile_photo': file_path}})
            return jsonify({'message': 'Profile photo updated successfully'}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        return jsonify({'error': 'Invalid file type'}), 400

@app.route('/edit_bio', methods=['POST'])
def edit_bio():
    if 'email' not in session:
        return redirect(url_for('login'))

    new_bio = request.form.get('bio')
    user_email = session['email']

    users_collection = mongo_db.get_collection('users')
    user = users_collection.find_one({'email': user_email})
    
    if user:
        # Update bio in the database
        users_collection.update_one(
            {'email': user_email},
            {'$set': {'bio': new_bio}}
        )

        # Redirect back to the profile page with the user's ID
        return redirect(url_for('profile', user_id=str(user['_id'])))
    else:
        flash('User not found.')
        return redirect(url_for('login'))

@app.route('/profile')
def simple_profile():
    if 'email' not in session:
        flash('You must be logged in to view this page.')
        return redirect(url_for('login'))

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    
    if user:
        user_id = str(user['_id'])
        return redirect(url_for('profile', user_id=user_id))
    else:
        flash('User not found.')
        return redirect(url_for('home'))

@app.route('/profile/<user_id>')
def profile(user_id):
    if 'email' not in session:
        return redirect(url_for('login'))

    profile_user = mongo_db.get_collection('users').find_one({'_id': ObjectId(user_id)})
    if not profile_user:
        return 'User not found', 404

    # Assuming followers and followings are stored as lists of user IDs in user documents
    followers = profile_user.get('followers', [])
    followings = profile_user.get('followings', [])
    posts = profile_user.get('posts', [])  # Assuming posts are stored in the user document

    is_following = False
    current_user = mongo_db.get_collection('users').find_one({'email': session['email']})
    if current_user:
        is_following = ObjectId(user_id) in current_user.get('followings', [])

    # Convert the ObjectId to string for template usage
    profile_user['_id'] = str(profile_user['_id'])
    if current_user:
        current_user['_id'] = str(current_user['_id'])

    return render_template('profile.html', profile_user=profile_user, current_user=current_user, is_following=is_following, followers=followers, followings=followings, posts=posts)

@app.route('/edit_name', methods=['POST'])
def edit_name():
    if 'email' not in session:
        flash('You need to login first.')
        return redirect(url_for('login'))
    
    user_email = session['email']
    new_name = request.form.get('name')

    if new_name:
        users_collection = mongo_db.get_collection('users')
        user = users_collection.find_one({'email': user_email})
        if user:
            result = users_collection.update_one(
                {'email': user_email},
                {'$set': {'name': new_name}}
            )
            if result.modified_count:
                flash('Your name has been updated.')
            else:
                flash('No changes were made.')
        else:
            flash('User not found.')
    else:
        flash('Name cannot be empty.')

    # Redirect to the profile page with the user's ID
    return redirect(url_for('profile', user_id=str(user['_id'])))

@app.route('/delete_post/<post_id>', methods=['DELETE'])
def delete_post(post_id):
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    if user:
        # Assuming each post is an object with 'id' and 'filename' keys
        post_to_delete = next((post for post in user['posts'] if post['id'] == post_id), None)
        
        if post_to_delete:
            # Delete the post from the database
            mongo_db.get_collection('users').update_one(
                {'_id': user['_id']},
                {'$pull': {'posts': {'id': post_id}}}
            )
            # Delete the image file from the filesystem
            os.remove(os.path.join( os.path.join(app.static_folder, post_to_delete['file_path'])))
            return jsonify({'success': True})
        else:
            return jsonify({'error': 'Post not found'}), 404
    else:
        return jsonify({'error': 'User not found'}), 404


@app.route('/follow', methods=['POST'])
def follow():
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    current_user_email = session['email']
    profile_user_id = request.json.get('profile_user_id')
    print(profile_user_id)

    current_user = mongo_db.get_collection('users').find_one({'email': current_user_email})
    profile_user = mongo_db.get_collection('users').find_one({'_id': ObjectId(profile_user_id)})

    if not profile_user or not current_user:
        return jsonify({'error': 'User not found'}), 404

    # Add current user to profile user's followers
    if ObjectId(current_user['_id']) not in profile_user.get('followers', []):
        mongo_db.get_collection('users').update_one(
            {'_id': ObjectId(profile_user_id)},
            {'$push': {'followers': ObjectId(current_user['_id'])}}
        )

    # Add profile user to current user's followings
    if ObjectId(profile_user_id) not in current_user.get('followings', []):
        mongo_db.get_collection('users').update_one(
            {'email': current_user_email},
            {'$push': {'followings': ObjectId(profile_user_id)}}
        )

    return jsonify({'message': 'Followed successfully'}), 200

@app.route('/unfollow', methods=['POST'])
def unfollow():
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    current_user_email = session['email']
    profile_user_id = request.json.get('profile_user_id')

    current_user = mongo_db.get_collection('users').find_one({'email': current_user_email})
    profile_user = mongo_db.get_collection('users').find_one({'_id': ObjectId(profile_user_id)})

    if not profile_user or not current_user:
        return jsonify({'error': 'User not found'}), 404

    # Remove current user from profile user's followers
    mongo_db.get_collection('users').update_one(
        {'_id': ObjectId(profile_user_id)},
        {'$pull': {'followers': ObjectId(current_user['_id'])}}
    )

    # Remove profile user from current user's followings
    mongo_db.get_collection('users').update_one(
        {'email': current_user_email},
        {'$pull': {'followings': ObjectId(profile_user_id)}}
    )

    return jsonify({'message': 'Unfollowed successfully'}), 200


@app.route('/home')
def home():
    if 'email' not in session:
        flash('You must be logged in to view this page.')
        return redirect(url_for('login'))

    users_collection = mongo_db.get_collection('users')
    users_data = users_collection.find()

    all_posts = []
    for user in users_data:
        user_id = str(user['_id'])
        for post in user.get('posts', []):
            # Ensure 'created_at' is present in the post dictionary
            if 'created_at' not in post:
                continue  # Skip this post if 'created_at' is missing

            # Calculate 'time ago' for each post
            time_ago = datetime.now() - post['created_at']
            formatted_time_ago = format_time_ago(time_ago)

            all_posts.append({
                'profile_photo': user.get('profile_photo', 'default_profile.png'),
                'user_name': user.get('name', user['email'].split('@')[0] + ' Kitchen'),
                'location': post.get('location', 'Unknown location'),
                'image_path': post['file_path'],
                'likes': len(post.get('likes', [])),  # Count the number of likes
                'comments': len(post.get('comments', [])),  # Count the number of comments
                'caption': post.get('caption', ''),
                'time_ago': formatted_time_ago,
                'post_id': post['id'],
                'created_at': post['created_at']  # Use this key for sorting
            })

    # Now sort the posts by 'created_at'
    sorted_posts = sorted(all_posts, key=lambda x: x['created_at'], reverse=True)

    current_user_email = session['email']
    current_user = users_collection.find_one({'email': current_user_email})

    return render_template('home.html', posts=sorted_posts, user=current_user)

def format_time_ago(time_delta):
    """
    Formats a datetime.timedelta object into a human-readable 'time ago' string.
    """
    # Example implementation; you might want to handle more cases or use a library like 'humanize'.
    seconds = int(time_delta.total_seconds())
    if seconds < 60:
        return f"{seconds} seconds ago"
    elif seconds < 3600:
        return f"{seconds // 60} minutes ago"
    elif seconds < 86400:
        return f"{seconds // 3600} hours ago"
    else:
        return f"{seconds // 86400} days ago"

@app.route('/like_post/<post_id>', methods=['POST'])
def like_post(post_id):
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    user_id = str(user['_id'])

    # Find the user document that contains the post
    post_data = mongo_db.get_collection('users').aggregate([
        {'$match': {'posts.id': post_id}},
        {'$unwind': '$posts'},
        {'$match': {'posts.id': post_id}},
        {'$project': {'posts.likes': 1}}
    ])

    try:
        post_likes = next(post_data)['posts']['likes']
    except StopIteration:
        return jsonify({'error': 'Post not found'}), 404

    # Check if user has already liked the post
    if user_id in post_likes:
        # User already liked the post, so unlike it
        mongo_db.get_collection('users').update_one(
            {'posts.id': post_id},
            {'$pull': {'posts.$.likes': user_id}}
        )
        action = 'unliked'
    else:
        # User has not liked the post, so like it
        mongo_db.get_collection('users').update_one(
            {'posts.id': post_id},
            {'$addToSet': {'posts.$.likes': user_id}}
        )
        action = 'liked'

    # Get the updated like count
    updated_post_data = mongo_db.get_collection('users').aggregate([
        {'$match': {'posts.id': post_id}},
        {'$unwind': '$posts'},
        {'$match': {'posts.id': post_id}},
        {'$project': {'posts.likes': 1}}
    ])
    updated_post_likes = next(updated_post_data)['posts']['likes']

    return jsonify({'action': action, 'likes_count': len(updated_post_likes)})

@app.route('/comment_post/<post_id>', methods=['POST'])
def comment_post(post_id):
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    comment_text = request.form.get('comment')

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})

    comment = {
        'user_id': str(user['_id']),
        'comment_text': comment_text
    }

    # Add the comment to the post
    if comment_text is None:
        return {"code":500,"data":"Comment can't be empty"}
    
    result = mongo_db.get_collection('users').update_one(
        {'posts.id': post_id},
        {'$push': {'posts.$.comments': comment}}
    )

    if result.modified_count == 0:
        return jsonify({'error': 'Post not found or update failed'}), 404
    updated_post_data = mongo_db.get_collection('users').aggregate([
        {'$match': {'posts.id': post_id}},
        {'$unwind': '$posts'},
        {'$match': {'posts.id': post_id}},
        {'$project': {'posts.comments': 1}}
    ])
    updated_post_comments = next(updated_post_data)['posts']['comments']

    return jsonify({'data': updated_post_comments}), 200


# for vendor home page

@app.route('/vendor_home/<user_id>')
def vendor_home(user_id):
    if 'email' not in session:
        return redirect(url_for('login'))

    profile_user = mongo_db.get_collection('users').find_one({'_id': ObjectId(user_id)})
    if not profile_user:
        return 'User not found', 404

    # Convert the ObjectId to string for template usage
    profile_user['_id'] = str(profile_user['_id'])

    # Convert ObjectId in followers and followings to strings
    profile_user['followers'] = profile_user.get('followers', [])
    profile_user['followings'] = profile_user.get('followings', [])

    # Calculate additional stats like total followers, followings and posts
    total_followers = len(profile_user['followers'])
    print(total_followers,"-tot")
    total_followings = len(profile_user['followings'])
    total_posts = len(profile_user.get('posts', []))

    # Pass these stats to the template
    return render_template('vendor_home.html',
                           profile_user=profile_user,
                           total_followers=total_followers,
                           total_followings=total_followings,
                           total_posts=total_posts)
 
@app.route('/upload_menu', methods=['POST'])
def upload_menu():
    if 'email' not in session:
        return jsonify({'error': 'Unauthorized'}), 401

    user_email = session['email']
    user = mongo_db.get_collection('users').find_one({'email': user_email})
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        # Save the file inside the static/uploads directory
        file_path = os.path.join('uploads', filename)  # Relative path
        full_path = os.path.join(app.static_folder, file_path)  # Full path

        try:
            # Ensure the uploads directory exists inside the static folder
            os.makedirs(os.path.join(app.static_folder, 'uploads'), exist_ok=True)
            # Save the file
            file.save(full_path)
            # Update the user's profile photo in MongoDB with the relative path
            # mongo_db.get_collection('users').update_one({'_id': user['_id']}, {'$set': {'profile_photo': file_path}})
            return jsonify({'message': 'Menu  updated successfully'}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        return jsonify({'error': 'Invalid file type'}), 400

@app.route('/logout')
def logout():
    session.pop('email', None)
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True,port=8000)