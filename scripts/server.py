from flask import Flask, request
import sys
import sqlite3

app = Flask(__name__, static_url_path='/static')

@app.route('/api/createuser', methods=['POST'])
def createuser():
#     print(request.form['username'], request.form['psw'], request.form['psw-repeat'], file=sys.stderr)
     if request.form['psw'] != request.form['psw-repeat']:
          return app.send_static_file('createacc_passwords_do_not_match.html')

     conn = sqlite3.connect('/home/ubuntu/database.db')
     c = conn.cursor()
     t = (request.form['username'], )
     c.execute("SELECT * from users WHERE usr=?", t)
     out = c.fetchone()

     if(out != None):
         return app.send_static_file("createacc_username_in_use.html")

     conn.close()

     return('Passwords match!')

@app.route('/')
def home():
     return app.send_static_file('createacc.html')

if __name__ == '__main__':
     app.run(debug=True, host='0.0.0.0', port=80)
