from flask import Flask, request, render_template_string
from run_sim import run_simulation

app = Flask(__name__)

HTML = """

<html>

<head>

<title>Smart Study Optimizer</title>

<style>

body{

font-family: Arial;

background-image:url('/static/bg.jpg');

background-size:cover;

background-position:center;

background-repeat:no-repeat;

background-attachment:fixed;

margin:0;

}

.container{

width:750px;

margin:40px auto;

background:rgba(255,255,255,0.95);

padding:25px;

border-radius:15px;

box-shadow:0px 8px 25px rgba(0,0,0,0.2);

}

h1{

text-align:center;

color:#1f3c88;

}

table{

width:100%;

border-collapse:collapse;

margin-top:10px;

}

th{

background:#3a7bd5;

color:white;

padding:10px;

}

td{

padding:10px;

text-align:center;

}

tr:nth-child(even){

background:#f2f2f2;

}

input{

padding:7px;

border-radius:6px;

border:1px solid #ccc;

}

.inputbox{

width:95%;

box-sizing:border-box;

}

.btn{

background:#3a7bd5;

color:white;

padding:12px 20px;

border:none;

border-radius:8px;

font-size:16px;

cursor:pointer;

}

.btn:hover{

background:#2c5282;

}

.result{

text-align:center;

color:#1f3c88;

margin-top:20px;

}

</style>

</head>

<body>

<div class="container">

<h1>🎓 Smart Study Optimizer</h1>

<form method="post">

<h3>Subjects</h3>

<table>

<tr>
<th>Subject Name</th>
<th>Current</th>
<th>Target</th>
<th>Difficulty</th>
</tr>

<tr>
<td><input name="name1" class="inputbox"></td>
<td><input name="cur1" class="inputbox"></td>
<td><input name="tar1" class="inputbox"></td>
<td><input name="diff1" class="inputbox"></td>
</tr>

<tr>
<td><input name="name2" class="inputbox"></td>
<td><input name="cur2" class="inputbox"></td>
<td><input name="tar2" class="inputbox"></td>
<td><input name="diff2" class="inputbox"></td>
</tr>

<tr>
<td><input name="name3" class="inputbox"></td>
<td><input name="cur3" class="inputbox"></td>
<td><input name="tar3" class="inputbox"></td>
<td><input name="diff3" class="inputbox"></td>
</tr>

<tr>
<td><input name="name4" class="inputbox"></td>
<td><input name="cur4" class="inputbox"></td>
<td><input name="tar4" class="inputbox"></td>
<td><input name="diff4" class="inputbox"></td>
</tr>

</table>

<br>

Gender:

<select name="gender">

<option value="">Select</option>
<option value="male">Male</option>
<option value="female">Female</option>

</select>

<br><br>

Period Fatigue (Only for Female):

<select name="period">

<option value="no">No</option>
<option value="yes">Yes</option>

</select>

<br><br>

Fatigue Factor:

<input name="fat" class="inputbox">

<br><br>

<center>

<input type="submit" value="Calculate Priority" class="btn">

</center>

</form>



{% if result %}

<h2 class="result">📊 Priority Results (Rank Order)</h2>

<table>

<tr>
<th>Subject</th>
<th>Priority</th>
<th>Rank</th>
</tr>

<tr>
<td>{{name1}}</td>
<td>{{p1}}</td>
<td>{{r1}}</td>
</tr>

<tr>
<td>{{name2}}</td>
<td>{{p2}}</td>
<td>{{r2}}</td>
</tr>

<tr>
<td>{{name3}}</td>
<td>{{p3}}</td>
<td>{{r3}}</td>
</tr>

<tr>
<td>{{name4}}</td>
<td>{{p4}}</td>
<td>{{r4}}</td>
</tr>

</table>

{% endif %}

</div>

</body>

</html>

"""


@app.route("/",methods=["GET","POST"])
def home():

    result=False

    if request.method=="POST":

        if(
        request.form["name1"]=="" or
        request.form["cur1"]=="" or
        request.form["tar1"]=="" or
        request.form["diff1"]=="" or

        request.form["name2"]=="" or
        request.form["cur2"]=="" or
        request.form["tar2"]=="" or
        request.form["diff2"]=="" or

        request.form["name3"]=="" or
        request.form["cur3"]=="" or
        request.form["tar3"]=="" or
        request.form["diff3"]=="" or

        request.form["name4"]=="" or
        request.form["cur4"]=="" or
        request.form["tar4"]=="" or
        request.form["diff4"]=="" or

        request.form["fat"]=="" or
        request.form["gender"]==""
        ):

            return render_template_string(HTML,result=False)


        fatigue=int(request.form["fat"])

        if request.form["gender"]=="female":
            if request.form["period"]=="yes":
                fatigue=fatigue+5


        names=[
        request.form["name1"],
        request.form["name2"],
        request.form["name3"],
        request.form["name4"]
        ]


        sim=run_simulation(

            request.form["cur1"],
            request.form["tar1"],
            request.form["diff1"],

            request.form["cur2"],
            request.form["tar2"],
            request.form["diff2"],

            request.form["cur3"],
            request.form["tar3"],
            request.form["diff3"],

            request.form["cur4"],
            request.form["tar4"],
            request.form["diff4"],

            fatigue
        )


        vals=sim.split()

        if "RESULT" in vals:

            i=vals.index("RESULT")

            priorities=[
            vals[i+1],
            vals[i+2],
            vals[i+3],
            vals[i+4]
            ]

            ranks=[
            int(vals[i+5]),
            int(vals[i+6]),
            int(vals[i+7]),
            int(vals[i+8])
            ]


            rows=[]

            for k in range(4):

                rows.append({
                "name":names[k],
                "priority":priorities[k],
                "rank":ranks[k]
                })


            rows.sort(key=lambda x:x["rank"])


            return render_template_string(

                HTML,

                result=True,

                name1=rows[0]["name"],
                name2=rows[1]["name"],
                name3=rows[2]["name"],
                name4=rows[3]["name"],

                p1=rows[0]["priority"],
                p2=rows[1]["priority"],
                p3=rows[2]["priority"],
                p4=rows[3]["priority"],

                r1=rows[0]["rank"],
                r2=rows[1]["rank"],
                r3=rows[2]["rank"],
                r4=rows[3]["rank"]

            )


    return render_template_string(HTML,result=False)


if __name__=="__main__":
    app.run(debug=True)
