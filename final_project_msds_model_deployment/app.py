from flask import Flask,render_template,url_for,redirect
from flask_wtf import FlaskForm
from wtforms import IntegerField,DecimalField,SubmitField
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)

app.config['SECRET_KEY'] = 'secretkey'

def predict_result(maxEV_2022, Barrels_2022, HRdivFB_2022, SLG_2021, SLG_2022, xwOBA_2021, xwOBA_2022, WAR_2021, WAR_2022, Medper_2021, Medper_2022, PA_2022):
    AVG_SLG = (SLG_2021 + SLG_2022) / 2
    sPA_2022 = round(np.sqrt(PA_2022))
    AVG_xwOBA = (xwOBA_2021 + xwOBA_2022) / 2
    AVG_WAR = (WAR_2021 + WAR_2022) / 2
    AVG_Medper = (Medper_2021 + Medper_2022) / 2
    arr = [maxEV_2022, Barrels_2022, HRdivFB_2022, AVG_SLG, AVG_xwOBA, AVG_WAR, AVG_Medper, sPA_2022]
    data = pd.DataFrame({'maxEV_2022':[maxEV_2022], 'Barrels_2022':[Barrels_2022], 'HR/FB_2022':[HRdivFB_2022], 'AVG_SLG':[AVG_SLG], 'AVG_xwOBA':[AVG_xwOBA], 'AVG_WAR':[AVG_WAR], 'AVG_Med%':[AVG_Medper], 'sPA_2022':[sPA_2022]})

    file = open('Model.pkl', 'rb')
    model = joblib.load(file)
    prediction = model.predict(data)
    return round(prediction[0])

class InfoForm(FlaskForm):
    Barrels_2022 = IntegerField("Number of barrels for the second season: ")
    maxEV_2022 = DecimalField("Maximum exit velocity for the second season: ")
    HRdivFB_2022 = DecimalField("Fly balls divided by home runs for the second season: ")
    SLG_2021 = DecimalField("Slugging percentage for the first season: ")
    SLG_2022 = DecimalField("Slugging percentage for the second seaason: ")
    xwOBA_2021 = DecimalField("xwOBA for the first year: ")
    xwOBA_2022 = DecimalField("xwOBA for the second year: ")
    WAR_2021 = DecimalField("First year WAR: ")
    WAR_2022 = DecimalField("Second year WAR: ")
    Medper_2021 = DecimalField("Average medium contact for the first year: ")
    Medper_2022 = DecimalField("Average medium contact for the second year: ")
    PA_2022 = IntegerField("Number of plate appearances for the second season: ")
    submit = SubmitField("Predict")

@app.route('/')
def about():
    return render_template('about.html')

@app.route('/projects')
def projects():
    return render_template('projects.html')

@app.route('/resume')
def resume():
    return render_template('resume.html')

@app.route('/model',methods=['GET','POST'])
def model():
    form = InfoForm()
    if form.validate_on_submit():
        maxEV_2022 = form.maxEV_2022.data
        Barrels_2022 = form.Barrels_2022.data
        SLG_2021 = form.SLG_2021.data
        SLG_2022 = form.SLG_2022.data
        xwOBA_2021 = form.xwOBA_2021.data
        xwOBA_2022 = form.xwOBA_2022.data
        WAR_2021 = form.WAR_2021.data
        WAR_2022 = form.WAR_2022.data
        Medper_2021 = form.Medper_2021.data
        Medper_2022 = form.Medper_2022.data
        PA_2022 = form.PA_2022.data
        HRdivFB_2022 = form.HRdivFB_2022.data
        prediction = predict_result(maxEV_2022, Barrels_2022, HRdivFB_2022, SLG_2021, SLG_2022, xwOBA_2021, xwOBA_2022, WAR_2021, WAR_2022, Medper_2021, Medper_2022, PA_2022)

        return render_template('predict.html',prediction=prediction)
    return render_template('model.html',form=form)

    if __name__ == '__main__':
        app.run()
