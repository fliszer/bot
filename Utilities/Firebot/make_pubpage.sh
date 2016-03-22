#!/bin/bash
historydir=~/.firebot/history
BODY=
TITLE=Firebot
SOPT=

while getopts 'bs' OPTION
do
case $OPTION  in
  b)
   BODY="1"
   ;;
  s)
   historydir=~/.smokebot/history
   TITLE=Smokebot
   SOPT=-s
   ;;
esac
done
shift $(($OPTIND-1))


if [ "$BODY" == "" ]; then
cat << EOF
<!DOCTYPE html>
<html><head><title>$TITLE Build Status</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Days since Jan 1, 2016', 'Benchmark Time (s)'],
EOF

MINTIME=`./make_timelist.sh $SOPT | sort -n -k 1 -t , | tail -30 | awk -F ',' 'BEGIN {min=1000000}{if ($2<min)min=$2}END{print min}'`
MAXTIME=`./make_timelist.sh $SOPT | sort -n -k 1 -t , | tail -30 | awk -F ',' 'BEGIN {max=0}      {if ($2>max)max=$2}END{print max}'`
./make_timelist.sh $SOPT | sort -n -k 1 -t , | tail -30 | awk -F ',' '{ printf("[%s,%s],\n",$1,$2) }'
SPREAD=`echo "scale=2; 100.0*($MAXTIME - $MINTIME)/$MINTIME+0.05" | bc`

cat << EOF
        ]);

        var options = {
          title: '',
          curveType: 'line',
          legend: { position: 'right' },
          colors: ['black'],
          pointSize: 5,
          hAxis:{ title: 'Day'},
          vAxis:{ title: 'Time (s)'}
        };
        options.legend = 'none';

        var chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

        chart.draw(data, options);
      }
    </script>

</head>
<body>
<h2>$TITLE Summary</h2>
<hr align='left'>
<h3>Status - `date`</h3>
EOF

CURDIR=`pwd`
cd $historydir
ls -tl *-????????.txt | awk '{system("head "  $9)}' | sort -t ';' -r -n -k 7 | head -1 | \
             awk -F ';' '{cputime="Benchmark time: "$9" s";\
                          if($9=="")cputime="";\
                          font="<font color=\"#00FF00\">";\
                          if($8=="2")font="<font color=\"#FF00FF\">";\
                          if($8=="3")font="<font color=\"#FF0000\">";\
                          printf("%s %s</font><br>\n",font,$1);\
                          printf("<a href=\"https://github.com/firemodels/fds-smv/commit/%s\">Revision: %s</a><br>\n",$font,$1);\
                          printf("Revision date: %s<br>\n",$2);\
                          if($9!="")printf("%s <br>\n",cputime);\
                          }' 
cd $CURDIR

cat << EOF
<h3>Timings</h3>

<div id="curve_chart" style="width: 500px; height: 300px"></div>
Min: $MINTIME (s)<br>
Max: $MAXTIME (s)<br>
Spread: $SPREAD %<br>
<h3>Manuals</h3>
<a href="http://goo.gl/n1Q3WH">Manuals</a>

<h3>History</h3>

EOF
fi

CURDIR=`pwd`
cd $historydir
ls -tl *-????????.txt | awk '{system("head "  $9)}' | sort -t ';' -r -n -k 7 | head -30 | \
             awk -F ';' '{cputime="Benchmark time: "$9" s";\
                          if($9=="")cputime="";\
                          font="<font color=\"#00FF00\">";\
                          if($8=="2")font="<font color=\"#FF00FF\">";\
                          if($8=="3")font="<font color=\"#FF0000\">";\
                          printf("<p>%s %s</font><br>\n",font,$1);\
                          printf("<a href=\"https://github.com/firemodels/fds-smv/commit/%s\">Revision: %s</a><br>\n",$4,$5);\
                          printf("Revision date: %s<br>\n",$2);\
                          if($9!="")printf("%s <br>\n",cputime);\
                          }' 
cd $CURDIR

if [ "$BODY" == "" ]; then
cat << EOF
<br><br>
<hr align='left'><br>

</body>
</html>
EOF
fi