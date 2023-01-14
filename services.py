import mysql.connector
import tensorflow as tf
import numpy as np
import time
from tensorflow.keras.models import Model, Sequential
from tensorflow.keras.utils import load_img,img_to_array,image_dataset_from_directory
from numpy import expand_dims


cnx = mysql.connector.connect(user='root', password='123456',
                              host='127.0.0.1',
                              database='django')
cnx.autocommit = True
cursor = cnx.cursor()

model_load = tf.keras.models.load_model('MobileNet')
model_mobileNet = Model(model_load.input,model_load.get_layer("fc1").output)

model_load_InceptionV3 = tf.keras.models.load_model('InceptionV3')
model_inceptionV3 = Model(model_load_InceptionV3.input,model_load_InceptionV3.get_layer("fc1").output)

model_load_VGG16 = tf.keras.models.load_model('VGG16')
model_VGG16 = Model(model_load_VGG16.input,model_load_VGG16.get_layer("fc1").output)

model_NLP = tf.keras.models.load_model('MLP_mobileNet_InceptionV3_VGG16_2')

route = "ApiSource/media"
# Show the model architecture
label = [
  "Actinic keratoses (akiec)",
  "Basal cell carcinoma (bcc)",
  "Benign keratosis-like lesions (bkl)",
  "Dermatofibroma (df)",
  "Melanoma (mel)",
  "Melanocytic nevi (nv)",
  "Pyogenic granulomas and hemorrhage (vasc)"
]
while True:
  query = ("SELECT image FROM MyApi_uploadimage Where predictions = '' ")
  cursor.execute(query)
  for (image,) in cursor:
    try:
      img = load_img(f"{route}/{image}",target_size=(128,128))
    except:
      continue
    img =  (expand_dims(img, 0)) /255
    x1 = model_mobileNet.predict(img).flatten()
    x2 = model_inceptionV3.predict(img).flatten()
    x3 = model_VGG16.predict(img).flatten()
    x = np.concatenate((x1,x2,x3), axis=None)
    a = model_NLP.predict(expand_dims(x, 0))
    index = np.argmax(a)
    if a[index] >= 0.5:
      predict = label[index]
    else:
      predict = "Unkown"
    query2 = "UPDATE MyApi_uploadimage SET predictions = %s WHERE image = %s "
    cursor.execute(query2,(str(predict),image))
  time.sleep(1)
cursor.close()
cnx.close()