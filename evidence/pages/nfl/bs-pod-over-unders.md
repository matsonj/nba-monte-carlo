---
queries:
  - pod_picks: nfl/bs_pod_over_unders_summary.sql
  - pod_records: nfl/bs_pod_over_unders_records.sql
title: BS Pod Over/Unders
sidebar_position: 4
---

# 2026 NFL BS Pod Over/Unders

Bill Simmons and Cousin Sal's regular-season win-total picks for the AFC and NFC. `Proj wins` is the current simulation average; `Proj` shows whether that projection is over or under the listed win total. Picks remain open until the regular season is complete. `On track` means the current win total is already on the selected side of the line.

[AFC episode transcript](https://podscripts.co/podcasts/the-bill-simmons-podcast/the-annual-afc-overunders-with-bill-simmons-cousin-sal-and-joe-house) · [NFC episode transcript](https://podscripts.co/podcasts/the-bill-simmons-podcast/the-annual-nfc-overunders-with-bill-simmons-cousin-sal-and-joe-house)

## Aggregate Records

<DataTable data={pod_records} rows=2>
    <Column id=speaker title="Picker"/>
    <Column id=settled_wins title="Settled wins"/>
    <Column id=settled_losses title="Settled losses"/>
    <Column id=settled_pushes title="Settled pushes"/>
    <Column id=open_picks title="Open picks"/>
    <Column id=on_track title="On track"/>
    <Column id=behind title="Behind"/>
</DataTable>

## Team-by-Team Picks

<Tabs>
    <Tab label="AFC">
        <DataTable data={pod_picks.filter(d => d.conf === "AFC")} rows=16>
            <Column id=division/>
            <Column id=team/>
            <Column id=win_total title="Win total"/>
            <Column id=proj_wins title="Proj wins"/>
            <Column id=proj title="Proj"/>
            <Column id=bill_pick title="Bill pick"/>
            <Column id=bill_status title="Bill status" align=center contentType=colorscale scaleColumn=bill_status_score colorMin=-1 colorMax=1 colorScale={['#9fadbd', '#0777b3']}/>
            <Column id=sal_pick title="Sal pick"/>
            <Column id=sal_status title="Sal status" align=center contentType=colorscale scaleColumn=sal_status_score colorMin=-1 colorMax=1 colorScale={['#9fadbd', '#0777b3']}/>
        </DataTable>
    </Tab>
    <Tab label="NFC">
        <DataTable data={pod_picks.filter(d => d.conf === "NFC")} rows=16>
            <Column id=division/>
            <Column id=team/>
            <Column id=win_total title="Win total"/>
            <Column id=proj_wins title="Proj wins"/>
            <Column id=proj title="Proj"/>
            <Column id=bill_pick title="Bill pick"/>
            <Column id=bill_status title="Bill status" align=center contentType=colorscale scaleColumn=bill_status_score colorMin=-1 colorMax=1 colorScale={['#9fadbd', '#0777b3']}/>
            <Column id=sal_pick title="Sal pick"/>
            <Column id=sal_status title="Sal status" align=center contentType=colorscale scaleColumn=sal_status_score colorMin=-1 colorMax=1 colorScale={['#9fadbd', '#0777b3']}/>
        </DataTable>
    </Tab>
</Tabs>
