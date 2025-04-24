#!/usr/bin/env python3

import sys
import time
import datetime
import argparse
import dateutil.parser

parser = argparse.ArgumentParser()
parser.add_argument('time', type=str, nargs='*', help='millisecond epoch or text date') # ? and * mean the same thing as in regular expressions (i.e. ? requires 0 or 1, and * requires 0 or more)
args = parser.parse_args()

def epoch_to_date_str(_epoch):
    return str(datetime.datetime.fromtimestamp(_epoch / 1000.0))


def date_str_to_epoch_millis(_date):
    return dateutil.parser.parse(_date).timestamp() * 1000


def difference_between_now_and_epoch_millis(_epoch_millis):
    now  = datetime.datetime.fromtimestamp(time.time())
    then = datetime.datetime.fromtimestamp(_epoch_millis/1000)

    rd = dateutil.relativedelta.relativedelta (now, then)
    rd_name  = [  "years",  "months",  "days",  "hours",  "minutes",  "seconds"]
    rd_value = [rd.years, rd.months, rd.days, rd.hours, rd.minutes, rd.seconds]

    time_ago = ''
    for i in range(len(rd_value)):
        if rd_value[i] != 0:
            if time_ago != '':
                time_ago += ', '
            time_ago += str(abs(rd_value[i])) + " " + rd_name[i]

    if (then > now):
        begin = "when will that be? 📡        : "
        end   = " from now (in the future)"
    else:
        begin = "when was that? 📜            : "
        end   = " ago (in the past)"

    return begin + time_ago + end


if (len(args.time) == 0):
    # just print current time
    epoch_millis = int(time.time() * 1000)

    print("millisecond epoch (now)      : " + str(epoch_millis))
    print("↳  converted to local time   : " + epoch_to_date_str(epoch_millis))
else:
    # try parsing the argument as both an integer and as a date string

    # so we can parse "ut.py 1969-12-31 16:00:02" as a single argument
    args_time_all = ' '.join(args.time)

    try:
        # is it an integer? this will throw a ValueError exception if it's not an integer argument
        epoch_millis = int(args_time_all)

        print("millisecond epoch (given)    : " + str(epoch_millis))
        print("↳  converted to local time   : " + epoch_to_date_str(epoch_millis))
        print(difference_between_now_and_epoch_millis(epoch_millis))
    except (ValueError, TypeError) as e:
        # it's not an integer, it's a string argument
        try:
            epoch_millis = int(date_str_to_epoch_millis(args_time_all))

            print("millisecond epoch (computed) : " + str(epoch_millis))
            print("↳  converted to local time   : " + epoch_to_date_str(epoch_millis))
            print(difference_between_now_and_epoch_millis(epoch_millis))
        except (ValueError) as e:
            print(str(e) + ': "' + args_time_all + '"')

print()

