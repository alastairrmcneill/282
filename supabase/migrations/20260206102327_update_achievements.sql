-- Update the names
UPDATE achievements
SET
  name = v.name,
  description = v.description
FROM (
  VALUES
    ('annualGoal2024', 'Munro Challenge 2024', 'Set your target for 2024 and see how many Munros the year brings.'),
    ('annualGoal2025', 'Munro Challenge 2025', 'A new year, new plans. How many Munros will you climb in 2025?'),
    ('annualGoal2026', 'Munro Challenge 2026', 'Another year on the hill. Set your goal and make it count.'),

    ('areaCompleteAngus', 'Angus Complete', 'Every Munro in Angus climbed. A small region, fully conquered.'),
    ('areaCompleteArgyll', 'Argyll Wrapped Up', 'All Argyll Munros completed. Sea lochs, ridges, and long days behind you.'),
    ('areaCompleteCairngorms', 'Master of the Cairngorms', 'Every Cairngorm Munro climbed. Big plateaus, big effort.'),
    ('areaCompleteFortWilliam', 'Fort William Finished', 'All Fort William Munros done. Scotland’s most serious ground ticked off.'),
    ('areaCompleteIslands', 'Island Munroist', 'Every island Munro climbed. Ferries, weather windows, and commitment rewarded.'),
    ('areaCompleteKintail', 'Kintail Conquered', 'All Kintail Munros completed. Sharp ridges and classic days out.'),
    ('areaCompleteLochLomond', 'Loch Lomond Complete', 'Every Munro around Loch Lomond climbed. Close to home, never easy.'),
    ('areaCompleteLochNess', 'Ness-side Navigator', 'All Loch Ness Munros finished. Long glens and quiet hills mastered.'),
    ('areaCompletePerthshire', 'Perthshire Finished', 'Every Perthshire Munro climbed. A region of steady progress and big totals.'),
    ('areaCompleteSutherland', 'Sutherland Signed Off', 'All Sutherland Munros completed. Few in number, big in feel.'),
    ('areaCompleteTorridon', 'Torridon Complete', 'Every Torridon Munro climbed. Some of Scotland’s finest hills behind you.'),
    ('areaCompleteUllapool', 'Ullapool Wrapped', 'All Ullapool Munros finished. Remote, rugged, and unforgettable.'),

    ('highestMunros10', 'Roof of Scotland', 'You’ve climbed the ten highest Munros in the country.'),
    ('lowestMunros10', 'Ground Level', 'The ten lowest Munros completed, but height isn’t everything.'),

    ('multiMunroDay2', 'Double Day', 'Two Munros in one day. Efficiency unlocked.'),
    ('multiMunroDay3', 'Triple Stack', 'Three Munros in a single day. Legs starting to notice.'),
    ('multiMunroDay4', 'Four on the Floor', 'Four Munros in one outing. A serious hill day.'),
    ('multiMunroDay5', 'Five-Bagger', 'Five Munros in a day. Planning, pacing, and persistence.'),
    ('multiMunroDay6', 'Six and Counting', 'Six Munros in one day. This is no longer casual.'),
    ('multiMunroDay7', 'Seven Summits', 'Seven Munros in a single day. Proper endurance territory.'),

    ('munroEveryMonth', 'All-Season Munroist', 'At least one Munro climbed in every month of the year.'),

    ('munrosCompletedAllTime001', 'First Foot on the Hill', 'Your first Munro climbed. The journey officially begins.'),
    ('munrosCompletedAllTime005', 'Finding Your Stride', '5 Munros completed. Momentum is building.'),
    ('munrosCompletedAllTime010', 'Well Underway', '10 Munros climbed. This is becoming a habit.'),
    ('munrosCompletedAllTime025', 'Quarter Century', '25 Munros done. Commitment confirmed.'),
    ('munrosCompletedAllTime050', 'Half a Hundred', '50 Munros climbed. A solid foundation laid.'),
    ('munrosCompletedAllTime082', 'Only 200 Left', '82 Munros completed. A few left to do.'),
    ('munrosCompletedAllTime100', 'Century Club', '100 Munros climbed. A landmark achievement.'),
    ('munrosCompletedAllTime182', 'Over the Hump', '182 Munros climbed. On the home stretch.'),
    ('munrosCompletedAllTime200', 'Double Century', 'Two hundred Munros completed. The endgame is in sight.'),
    ('munrosCompletedAllTime282', 'Munroist Complete', 'All 282 Munros climbed. A full round, properly earned.'),

    ('nameBen', 'Big Ben', 'Every Ben, Beinn, and Bheinn climbed. A lot of “Bens” ticked off.'),
    ('nameCarn', 'I Carn-y Do This Anymore', 'All the Carns and Cairns completed. Name repetition conquered.'),
    ('nameMeall', 'Meall Deal', 'Every Meall climbed. A surprisingly long list finished.'),
    ('nameSgurr', 'This Sgurr Is Tough', 'All Sgurrs, Sgors, and Sgorrs climbed. Pointy hills, one by one.'),
    ('nameStob', 'Stob Messing Around', 'Every Stob completed. No more excuses left.')
) AS v(id, name, description)
WHERE achievements.id = v.id;

-- Delete a few I don't like
DELETE FROM achievements
WHERE id IN ('munrosCompletedAllTime150', 'munrosCompletedAllTime250');
