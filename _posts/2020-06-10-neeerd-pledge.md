---
layout: single
classes: wide
title:  "Analysing cricket statistics in pandas"
date:   2020-04-04 10:44:36 +1100
categories: pandas
excerpt: "... how many Yak's can I shave in (several) days?"
header:
  overlay_image: /assets/images/cricket.jpg
  overlay_filter: 0.5
  caption: "Photo credit: Image by Lisa scott from Pixabay"
---

*Note: you can download the jupyter notebook for this post [here](/assets/notebooks/nerdpledge_blog.ipynb) and the CSV files I used: [1](assets/csv/men_test_player_innings_stats_-_19th_century.csv) [2](assets/csv/men_test_player_innings_stats_-_20th_century.csv) [3](assets/csv/men_test_player_innings_stats_-_20th_century.csv) [4](assets/csv/all_test_innings.csv)*

It's time for some [neeeeerd pledge](https://finalwordcricket.com/). I was talking to Adam and Geoff and though they run a segment called nerd pledge, I discovered they really need to up their cricket nerd stats game. So I'm here to help.

The problem is, writing custom queries is difficult if it's not something obvious on [statsguru](https://stats.espncricinfo.com/ci/engine/stats/index.html). So I'm going to answer a couple of questions:

- what is the most number of innings in a row a player has made greater than 40?
- which team has scored the most innings in a row less than 200?

This type of consecutive stat is actually quite a hard thing to do, sounds like a database task. This will be a ramble of my journey to answer these questions, but my goal is to have a "generic query" and then produce answer to that generic query. Okay, let's find some data!

Ie downloaded the files we need from [this dataset](https://www.kaggle.com/cclayford/cricinfo-statsguru-data/data). I just run these bash commands to rename the files for easier shell handling

```bash
# replace space with underscores, spaces are yukky
find *.csv -exec rename 's/\s/_/g' {} \;

# make all files lowercase
find *.csv -exec rename 'y/A-Z/a-z/' {} \;

#To fix up the headings, we do the same for the first line in all the csv files.
#
#1s/.*/\L&/ < on the first line, make sure all characters are lowercase \L
#1s/ /_/g ... on the first line, replace all spaces with underscores, globally
find *.csv -exec sed -i '1s/.*/\L&/;1s/ /_&/' {} \;
```

I did attempt to start this with SQL, but I found it such a pain that I decided to best tool is the one you've vaguely used before, so we're going with [pandas](https://pandas.pydata.org/). I will spare you my SQL adventure, it got a bit messy. 🍻🤢

Okay that's it. We've done the file processing, now to load them all into jupyter. 

I'm just going to be looking at the Men's test individual data. But you could do the same for the women, ODIs, etc. Just load those into the dataframe instead.

```python
import pandas as pd
import numpy as np
import glob
all_files = glob.glob('data/men_test_player_innings_stats_-_*.csv')

# low_memory=False just tries to figure out the data type of large files.
# we don't really need this, because we'll fix these later.
df = pd.concat((pd.read_csv(f, low_memory=False) for f in all_files))

```

There's a few things we should do before we can start processing the data.

- drop the duplicate rows
- change the type of data to the appropriate data type in each column (I *definitely* knew about this before starting the post, yep, *definitely*)
- sort by date - which will be a handy default

```python
df = df.drop_duplicates()

int_cols = ['innings_runs_scored_num', 'innings_minutes_batted', 
            'innings_batted_flag', 'innings_not_out_flag', 'innings_bowled_flag',
            'innings_balls_faced', 'innings_boundary_fours',
            'innings_boundary_sixes', 'innings_maidens_bowled',
            'innings_runs_conceded', 'innings_wickets_taken',
            '4_wickets', '5_wickets', '10_wickets'
           ]

for col in int_cols:
    # use to_numeric to convery the - to NaN (not-a-number)
    # "Int32" has mixed NaNs and integers
    df[col] = pd.to_numeric(df[col], errors='coerce').astype("Int32")

df.innings_economy_rate = pd.to_numeric(df.innings_economy_rate, errors='coerce')
df.innings_date = pd.to_datetime(df.innings_date, infer_datetime_format=True)
df = df.sort_values(by=['innings_date'])
```

Okay, so now we've gotten to the point where we hoped we would have started, clean data, I guess. How do we know we haven't fucked something up? 

Well, Don Bradman's test batting average was 99.94, how about we write a function to check the average is correct. 

The average of a batter is the number of runs scored in their career minus the number of times they have been dismissed.

So we can write a function for each.

```python
def get_total_runs(player):
    return df.loc[df['innings_player'] == player, 'innings_runs_scored_num'].sum()

def times_dismissed(player):
    num_innings = len(df.loc[df['innings_player'] == player, 'innings_runs_scored_num'].dropna())
    not_out = df.loc[df['innings_player'] == player, 'innings_not_out_flag'].sum()
    return num_innings - not_out

def get_average(player):
    runs = get_total_runs(player)
    dismissed = times_dismissed(player)
    if dismissed == 0:
        return np.nan
    return runs / dismissed
print(get_average('DG Bradman'))
```

    99.94285714285714

Fuckn yeh boooooiiiii! 😎

That was fun an all, but really, what we want is to do some fucking number crunching here. We can calculate the average of every player in the history of the game.

That will tell us who the real greatest player of all time is.

First we want to get all the players...


```python
all_players = df.innings_player.drop_duplicates()
```
That will just give us a pandas Series, but I want to make it into a DataFrame and add the column for the average for each player

```python
all_players = pd.DataFrame(all_players)
```
You can use the `apply` function to apply the function to all values, who'd have thought that's what it would do?

```python
all_players['average'] = all_players.innings_player.apply(get_average)
```

After that we should filter out the infinite and not-a-number results

```python
# filter out infinite and not-a-number results
all_players.replace([np.inf, -np.inf], np.nan, inplace=True)
all_players.dropna(inplace=True)
```

Next we can displayer the results from highest to lowest. To reveal the best batsman of all time....

```python
all_players.sort_values(by=['average'], ascending=False, inplace=True)
print(all_players[:10])
```

          innings_player     average
    22755   KR Patterson  144.000000
    66931   AG Ganteaume  112.000000
    48719       Abid Ali  107.000000
    50574     DG Bradman   99.942857
    62077       MN Nawaz   99.000000
    60884  VH Stollmeyer   96.000000
    85275       DM Lewis   86.333333
    69175     Abul Hasan   82.500000
    91237     RE Redmond   81.500000
    30714    DJ Mitchell   73.000000


Holy fuck. This can't be fucking real.

![Kurtis the goat](/assets/images/kurtis.png)

It fucking is!

Whoa, mind is actually blown. Okay, let's just make sure our data is all good, what does it take to caluculate the number of ducks a player got in their career? So the number of ducks is the number they scored 0 and were also dismissed, so we can do a simple calculate to figure out how many times Don Bradman got a duck:

```python
def get_all_player_stats(player):
    # return the entire dataframe but filtered for that player
    return df.loc[df['innings_player'] == player]

def num_ducks(player):
    all_stats = get_all_player_stats(player)
    ducks = all_stats[(all_stats.innings_not_out_flag == 0) & (all_stats.innings_runs_scored_num == 0)]
    return len(ducks)
print(f"The Don got {num_ducks('DG Bradman')} ducks")
```

    The Don got 7 ducks


Okay, so we've done that for the simple stuff. Now we're going to start answering the real questions, that stats that statsguru doens't want you to know. Won't let you know. Actively withholding important cricketing knowledge from you! Let's get started! 

So we want to set up a function that get the *number of times a condition matches in a row*. I'm using `np.where(condition)` to add an additional column to mark all the times the condition we want occurs. Then, we can compare that version with a shifted version, and see where they are not equal, to see where a change is.

Then use the *cumulative sum* to sum up each group. Here's the code:

```python
def get_all_player_stats(player, data):
    # return the entire dataframe but filtered for that player
    return data[data['innings_player'] == player]

def num_matches(test, col, test_num, df_data, greater, individual=True):
    # https://stackoverflow.com/questions/40068261/pandas-dataframe-find-longest-consecutive-rows-with-a-certain-condition
    # Special mention to the above post for this solution.

    # make a copy so we don't modify the original data
    data = df_data.copy()
    data = data[data[col] != np.nan]

    # we set a condition_true column for all data that matches our condition
    # TODO: investigate df.query for this
    if greater:
        data['condition_true'] = np.where(data[col] > test_num, True, False)
    else:
        data['condition_true'] = np.where(data[col] < test_num, True, False)
    all_stats = get_all_player_stats(test, data)
    
    # magic to find the consecutive differences, thanks internet!
    # compare the conditions with a shifted version to find the groups
    df_bool = all_stats['condition_true'] != all_stats['condition_true'].shift()
    # take the cumulitive sum to get the size of each group
    df_cumsum = df_bool.cumsum()
    # grouby the size of each group (this has both match and not match)
    groups = all_stats.groupby(df_cumsum)

    # get the aggregate and remove a useless column
    group_counts = groups.agg({col: ['count', 'min', 'max']})
    group_counts.columns = group_counts.columns.droplevel()

    # check if it is actually a mathc
    if greater:
        group_counts = group_counts[group_counts['min'] > test_num]
    else:
        group_counts = group_counts[group_counts['max'] < test_num]

    # retun the count
    max_count = group_counts['count'].max()
    return max_count
```

So now we've got the function that gives us the number of consecutive matches. We can use the `apply` function to apply the function to each player, like we did to get the averages. I used the `args` parameter to pass additional values to the function we're using. Swoit!

This version is currently a bit bad, because it only does less than / greater than conditions. I'll fix this eventually, hopefully.

What we're doing here, is getting the number of times a player has scored more than 40 in a row.
```python
# Enter these values to match a condition
match_name = 'greater_40'
column = 'innings_runs_scored_num'
greater_than = True
condition_number = 40

# comment out one of these lines to match the dataset you want
match_data = df.copy()
# match_data = team_innings.copy()


all_players['greater_40'] = all_players.innings_player.apply(
    num_matches,
    # this is where they are entered, I'll make this nicer later.
    args=(column, condition_number, match_data, greater_than))
all_players.sort_values(by=['greater_40'], ascending=False, inplace=True)
print(all_players[:5])

```

          innings_player    average  greater_40
    28904      JH Kallis  55.255230        10.0
    84190      ED Weekes  58.618421         9.0
    99630  Javed Miandad  52.571429         8.0
    19156       SR Waugh  51.060748         8.0
    57567      EJ Barlow  45.745455         8.0

Jacques Kallis is a total boss.

But we want more than that though, right! When the hell *was* those innings. We want to extract the match from the original dataset.

Let's give it a go, and I am just learning `pandas`, I'm sure there is a `groupby` way to do this, but it's 1am and I don't care.

```python
def num_matches_group(test, col, test_num, df_data, greater, individual=True):
    # https://stackoverflow.com/questions/40068261/pandas-dataframe-find-longest-consecutive-rows-with-a-certain-condition
    # Special mention to the above post for this solution.
    data = df_data.copy()
    data = data[data[col] != np.nan]
    if greater:
        data['condition_true'] = np.where(data[col] > test_num, True, False)
    else:
        data['condition_true'] = np.where(data[col] < test_num, True, False)
#     print(data)
    if individual:
        all_stats = get_all_player_stats(test, data)
    else:
        all_stats = get_all_teams_stats(test, data)
    df_bool = all_stats['condition_true'] != all_stats['condition_true'].shift()
    df_cumsum = df_bool.cumsum()
    groups = all_stats.groupby(df_cumsum)

    # this is the worst code I've ever written.
    # please don't judge
    max_len = 0
    resulting_df = None
    for g in groups:
        if g[1].condition_true.all() == True:
            if len(g[1]) > max_len:
                max_len = len(g[1])
                resulting_df = g[1]
    return max_len, resulting_df

```

Okay that's our messy function, I can't explain it now, but the internet helped a lot.

```python
top_player = all_players.iloc[0,0]

num, scores = num_matches_group(top_player, column, condition_number, df, greater_than, True)

cols_to_print = ['innings_player', 'innings_runs_scored', 'opposition' ,'ground', 'innings_date', 
                 'innings_minutes_batted', 'innings_balls_faced']
print(scores[cols_to_print])
```

          innings_player innings_runs_scored     opposition        ground  \
    10166      JH Kallis                  43     v Pakistan    Faisalabad   
    10151      JH Kallis                  44  v West Indies  Johannesburg   
    9476       JH Kallis                 158  v West Indies  Johannesburg   
    9459       JH Kallis                 177  v West Indies        Durban   
    9536       JH Kallis                130*  v West Indies     Cape Town   
    9784       JH Kallis                  73  v West Indies     Cape Town   
    9537       JH Kallis                130*  v West Indies     Centurion   
    9489       JH Kallis                150*  v New Zealand      Hamilton   
    9679       JH Kallis                  92  v New Zealand      Hamilton   
    9798       JH Kallis                  71  v New Zealand      Auckland   
    
          innings_date  innings_minutes_batted  innings_balls_faced  \
    10166   2003-10-24                     174                  113   
    10151   2003-12-12                      96                   72   
    9476    2003-12-12                     411                  297   
    9459    2003-12-26                     479                  344   
    9536    2004-01-02                     262                  191   
    9784    2004-01-02                     207                  145   
    9537    2004-01-16                     247                  199   
    9489    2004-03-10                     406                  312   
    9679    2004-03-10                     239                  177   
    9798    2004-03-18                     165                  127   
 

So, the innings was 2003-2004 when peak Jacques, 5 centuries in 6 fucking innings, what a monster.

So that lets us get all the innings that match. It's horrible code, I know, there has to be something that does it in one line. But I want to get this out the door working, and fix the computer-science-nerd-wank later.

So what if we wanted to perform the same action for a team innings. Well, the data we downloaded did not have all the indvidual team innings, unfortunately. But the data does exist on statsguru. So, I've modified a scraper that I found online to download the data. You can check out the [repo here](https://github.com/obrasier/statsguru-scraper)

Here's the relevent part:

```python
# replace the URL to the search query we want.
self.baseurl = "http://stats.espncricinfo.com/ci/engine/stats/index.html?class=1;orderby=start;page=%s;template=results;type=team;view=innings"
```

The score is not a nice integer of runs, so we can do maths on things with a `/`, so I added a runs column.

```python
# the runs are the number before the /, if it exists
runs = score.split('/')[0]
if runs == 'DNB':
    runs = 0
values.insert(2, runs)
```

Some of the balls per over was not 6, but is says when it wasn't. So I added a `balls_per_over` so it's possible to calculate the number of deliveries in each innings if needed.

```python
overs_and_balls = values[2].split('x')
values[2] = overs_and_balls[0]
balls_per_over = 6
if len(overs_and_balls) == 2:
    balls_per_over = overs_and_balls[1]
values.insert(3, balls_per_over)

```

Okay... that ran I the scraper from the internet required only 1 line change to actually work. Amazing.

```bash
$ python scraper.py
print('All done')
```

Noice.

We have all the innings now, with the following headings.

```python
all_innings_file = 'data/all_test_innings.csv'
all_innings = pd.read_csv(all_innings_file)
all_innings.start_date = pd.to_datetime(all_innings.start_date, infer_datetime_format=True)
all_innings.runs = pd.to_numeric(all_innings.runs, errors='coerce').astype("Int64")

all_teams = pd.DataFrame(all_innings.team.drop_duplicates())


# Enter these values to match a condition
match_name = 'under_200'
column = 'runs'
greater_than = False
condition_number = 200

# apply to to the teams instead of persons innings like before
all_teams[match_name] = all_teams.team.apply(
    num_matches,
    args=(column, condition_number, all_innings, greater_than, False))
all_teams.sort_values(by=[match_name], ascending=False, inplace=True)

# get the worst team
worst_team = all_teams.iloc[0,0]
print(worst_team)

amount, condition_innings = num_matches_group('Australia', 'runs', 200, all_innings, False, False)

columns_to_print = ['team', 'score', 'overs', 'opposition', 'ground', 'start_date']
print(amount)
print(condition_innings[columns_to_print])
```

    Australia
    21
              team score  overs opposition      ground start_date
    80   Australia   123  118.3  v England  Manchester 1886-07-05
    83   Australia   121   82.3  v England      Lord's 1886-07-19
    84   Australia   126  111.1  v England      Lord's 1886-07-19
    86   Australia    68   60.2  v England    The Oval 1886-08-12
    87   Australia   149   97.0  v England    The Oval 1886-08-12
    89   Australia   119  113.1  v England      Sydney 1887-01-28
    91   Australia    97  107.0  v England      Sydney 1887-01-28
    93   Australia    84   55.1  v England      Sydney 1887-02-25
    95   Australia   150  110.0  v England      Sydney 1887-02-25
    97   Australia    42   37.3  v England      Sydney 1888-02-10
    99   Australia    82   69.2  v England      Sydney 1888-02-10
    100  Australia   116   71.2  v England      Lord's 1888-07-16
    102  Australia    60   29.2  v England      Lord's 1888-07-16
    104  Australia    80   90.3  v England    The Oval 1888-08-13
    106  Australia   100   69.2  v England    The Oval 1888-08-13
    108  Australia    81   52.2  v England  Manchester 1888-08-30
    109  Australia    70   31.1  v England  Manchester 1888-08-30
    117  Australia   132   86.0  v England      Lord's 1890-07-21
    119  Australia   176  140.2  v England      Lord's 1890-07-21
    121  Australia    92   65.2  v England    The Oval 1890-08-11
    123  Australia   102   60.2  v England    The Oval 1890-08-11

Whoa, after a strong start, Australia have by far the longest losing streak. Sad, pandas gave me sad pandas. It's so much more than the 

So it works! We answered the queries, but it's a bit bloody clunky. I'm going to just submit this post now, but I will edit it. Because I'm sure I should have been using [df.query](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.query.html) this whole time to make it easier to write generic queries instead of the filtering I've been doing. 
