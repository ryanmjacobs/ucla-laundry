#!/usr/bin/env Rscript

# run extractions
system("bash consolidate.sh > final.csv")
system("ruby daily.rb final.csv")

colors = c(
    rgb(1,0,0,0.5), # red
    rgb(0,0,1,0.5)  # blue-purple
)
WEEKDAYS <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
WEEKDAYS_FULL <- c("Sunday", "Monday", "Tuesday", "Wednesday",
                   "Thursday", "Friday", "Saturday")

draw_legend <- function() {
    legend("topleft", legend=c("dryers", "washers"), fill=colors, horiz=F)
}

hour_vs_usage <- function(day) {
    w <- scan(paste("washers_hour_", day, ".count", sep=""))
    d <- scan(paste( "dryers_hour_", day, ".count", sep=""))

    # dryers
    hist(d, col=colors[1],
         breaks=24*2,
         axes=F, xlab="Hour", ylab="Usage", mgp=c(2.5,1,0),
         main="Hour of Day vs. Machine Usage")
    box()

    if (day != "") {
        mtext(paste(WEEKDAYS_FULL[day+1], "- Hedrick Hall"), line=0.5)
    } else {
        mtext("AVERAGE - Hedrick Hall", line=0.5)
    }

    # washers
    hist(w, add=T, col=colors[2], breaks=24*2)

    # x axis for 24-hours
    axis(side=1, at=c(0:24))

    # y-axis, between 0 and 1
    mtext("0%", at=-2, line=-25.5)
    mtext("100%", at=-2.3, line=-1.3)

    draw_legend()
}

weekday_vs_usage <- function() {
    wash <- read.csv("washers_weekday.count")
    dry <- read.csv( "dryers_weekday.count")

    ylim <- c(0, 1.1*max(c(dry$count, wash$count)))

   #barplot(dry$count,#xaxt="n",#col=colors,
    barplot(dry$count, ylim=ylim, axes=F,
         names=WEEKDAYS, col="#FF7F7F",
         xlab="Weekday", ylab="Usage", mgp=c(2.5,1,0),
         main="Weekday vs. Relative Machine Usage")
    mtext("Hedrick Hall", line=0.5)

    par(new=T)
    barplot(wash$count, ylim=ylim, axes=F, col="#7F7FFF")

    # y-axis, between 0 and 1
    mtext("0%", at=-0.5, line=-25.5)
    mtext("100%", at=-0.6, line=-1.3)

    legend("topright", legend=c("dryers", "washers"), fill=colors, horiz=F)
    box()
}

hour_vs_usage("")
weekday_vs_usage()
for (day in c(0:6)) {
   hour_vs_usage(day)
}
