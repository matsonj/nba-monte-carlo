---
title: mdsinabox - a sports monte carlo simulator
---

<GithubStarCount user='matsonj' repo='nba-monte-carlo'/>

Welcome to the [NBA monte carlo simulator](https://github.com/matsonj/nba-monte-carlo) project. Evidence is used as the as data visualization & analysis part of [MDS in a box](https://www.dataduel.co/modern-data-stack-in-a-box-with-duckdb/).

This project leverages duckdb, make, dbt, and evidence and builds and runs about once per day in a github action. You can learn more about this on [the about page](/about).

### Want to track what I am cooking up next? Join the email list.

<label>
    <input
        type="email" 
        placeholder="Type your email..." 
        bind:value="{email}" 
        style="border: 2px solid #DE4500; border-radius: 5px;"
    />
</label>

<a href="{prefilledLink}" target="_blank" on:click={handleClick}>
    <button class="submit-button" disabled={isClicked}>Subscribe</button>
</a>

## [NBA Model](/nba)

## [NFL Model](/nfl)

## [NCAA Football Model](/ncaaf)

<script>
    let email = "";
    let src = "mdsinabox-home";
    let isClicked = false;

    $: prefilledLink = `https://docs.google.com/forms/d/e/1FAIpQLSeiRdk9saFMRfrgV6k7izrs0SfmpptVd4M6I3tUH9jAumleKQ/formResponse?usp=pp_url&entry.1761363524=${email}&entry.1932146161=${src}&submit=Submit`;

    function handleClick() {
        isClicked = true;
    }

</script>

<style>
    .submit-button {
        border-radius: 8px;
        background-color: #DE4500;
        border: none;
        color: lightgrey;
        padding: 2px 6px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-size: 14px;
        margin: 4px 2px;
        cursor: pointer;
    }
</style>
