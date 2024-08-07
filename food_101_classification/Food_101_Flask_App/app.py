from flask import Flask,render_template,url_for,redirect,send_from_directory
from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed, FileRequired
from wtforms import SubmitField
from flask_uploads import UploadSet, IMAGES, configure_uploads
import pandas as pd
import numpy as np
import tensorflow as tf
import matplotlib.image as mpimg
import os



app = Flask(__name__)

app.config['SECRET_KEY'] = 'secretkey'
app.config['UPLOADED_PHOTOS_DEST'] = 'uploads'


photos = UploadSet('photos', IMAGES)
configure_uploads(app, photos)

model = tf.keras.models.load_model("Food_101_fine_tune.keras")

classes = []
with open("food_101_classes.txt") as f:
    for line in f.readlines():
        classes.append(line.split("\n")[0])

def load_and_process_image(file_url):
    img = mpimg.imread(file_url)
    return img

def generate_preds(img):
    pred_probs = model.predict(tf.image.resize(tf.expand_dims(img, axis=0), [224, 224]))
    probs_list = list(tf.squeeze(pred_probs, axis=0).numpy())
    probs = []
    pred_classes = []

    for prob in probs_list:
        if prob >= 0.1:
            probs.append(prob)
            pred_classes.append(classes[probs_list.index(prob)])

    df = pd.DataFrame({"probs": probs,
                       "pred_classes": pred_classes}).sort_values(by=["probs"], ascending=False)

    probabilities = list(df["probs"])
    class_list = list(df["pred_classes"])

    class_capital = []
    for i in range(len(class_list)):
        u = [word.capitalize() for word in class_list[i].split('_')]
        v = " ".join(u)
        class_capital.append(v)
    sen_list = []
    for i in range(len(probabilities)):
        sen_list.append(f"{class_capital[i]} with a probability of {round(probabilities[i] * 100, 2)}%.")
    return sen_list




@app.route('/uploads/<filename>')
def get_file(filename):
    return send_from_directory(app.config['UPLOADED_PHOTOS_DEST'], filename)



class UploadForm(FlaskForm):
    photo = FileField('Choose File', validators=[FileAllowed(['jpeg']), FileRequired()])
    submit = SubmitField('Upload')


@ app.route('/', methods=['GET', 'POST'])
def upload_image():
    form = UploadForm()
    if form.validate_on_submit():
        for file in list(os.listdir(app.config['UPLOADED_PHOTOS_DEST'])):
            os.remove(app.config['UPLOADED_PHOTOS_DEST'] + "\\" + file)
        filename = photos.save(form.photo.data)
        file_url = url_for('get_file', filename=filename)
        img = load_and_process_image(form.photo.data)
        sen_list = generate_preds(img)


    else:
        file_url = None
        sen_list = None



    return render_template('model.html', form=form, file_url=file_url, sen_list=sen_list)



if __name__ == '__main__':
    app.run(debug=True)
