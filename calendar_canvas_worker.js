WorkerScript.onMessage = function(message) {
    var processedEvents =  dayEventsMap(message.events)
    WorkerScript.sendMessage({'reply': processedEvents})
}

function sortByStartAndSize(eventA, eventB)
{
    var sort = sortEventsByStart(eventA, eventB)
    if (sort === 0)
        sort = sortEventsBySize(eventA, eventB)
    return sort
}

function sortEventsByStart(eventA, eventB)
{
        if (eventA.startTime < eventB.startTime)
            return -1
        else if (eventA.startTime > eventB.startTime)
            return 1
        else
            return 0
}

function sortEventsBySize(eventA, eventB)
{
    var eventAEndTime = eventA.endTimeInSecs
    var eventBEndTime = eventB.endTimeInSecs
    if (eventAEndTime > eventBEndTime)
        return -1
    else if (eventAEndTime < eventBEndTime)
        return 1
    return 0
}

/*
 * look for the minumum available 'y' on a list of events
 */
function findOptimalY(intersections)
{
    if (intersections.length === 0)
        return 0

    var found
    var optimalY = 0
    while(true) {
        found = false
        for(var i=0; i < intersections.length; i++) {
            if (optimalY === intersections[i].y) {
                found = true
                break
            }
        }
        if (found)
            optimalY++
        else
            return optimalY
    }
}

function dayEventsMap(eventsInfo)
{
    eventsInfo.sort(sortByStartAndSize)

    // intersections
    // =============
    // calculate the intersection of each event
    var lines = []
    for(var i=0; i < eventsInfo.length; i++) {
        var eventA = eventsInfo[i]
        line = [eventA]
        for(var y=0; y < eventsInfo.length; y++) {
            if (y === i)
                continue
            var eventB = eventsInfo[y]
            if ((eventA.startTime < eventB.endTime) &&
                (eventB.startTime < eventA.endTime)) {
                line.push(eventB)
            }
        }
        eventA.intersectionCount = line.length - 1
        lines.push(line)
    }

    // calculate 'y' position
    // ======================
    // based on the intersections calculate the y position of each event
    // the order will be based on start and duration, events that start earlier will be first
    // for events with the same start time, the event with big duration will be first
    for (var l=0; l < lines.length; l++) {
        var time = -1

        var line = lines[l]
        var eventA = line[0]
        if (eventA.y === -1) {
            eventA.y = findOptimalY(line)
        }
        var time = eventA.startTime
        for (var i=1; i < line.length; i++) {
            var event = line[i]
            if ((event.startTime === time) && (event.y === -1)) {
                event.y = findOptimalY(line)
            }
        }
    }

    // calculate the 'width' of event
    // ==============================
    // the number of events in the same line will determine the proportion used
    // to draw the event. The 'width' value will be something btw 1.0 and 0.1
    for (var l=0; l < lines.length; l++) {
        var line = lines[l]
        var eventA = line[0]
        var maxY = eventA.y
        for (var i=1; i < line.length; i++) {
            var event = line[i]
            if (maxY < event.y)
                maxY = event.y
        }
        if (maxY > 0)
            eventA.width = 1 / (maxY + 1)
    }

    return eventsInfo
}
