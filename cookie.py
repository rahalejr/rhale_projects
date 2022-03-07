from flask import Flask
from flask import request
from flask import make_response

app = Flask(__name__)


@app.route("/")
@app.route("/cookies/")
def cookies():

    cookies = request.cookies
    stored_cookies = [cookies.get('firstcookie'),cookies.get('secondcookie')]

    out = ''
    for i in stored_cookies:
        if i != None:
            out += f"{i} <br>"
    if len(out) > 0:    
        res = make_response(out,200)
    else: res = make_response('No cookies',200)

    res.set_cookie('firstcookie', 'I have cookie #1', max_age=10)
    res.set_cookie('secondcookie', 'I have cookie #2')

    return res


if __name__ == '__main__':
    app.run(debug=True)
