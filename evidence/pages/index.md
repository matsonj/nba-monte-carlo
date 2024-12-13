---
title: mdsinabox - a sports monte carlo simulator
---

<GithubStarCount user='matsonj' repo='nba-monte-carlo'/>

A fast, free and open-source Modern Data Stack (MDS) that can be fully deployed on your laptop or to a single machine. 

This project implements a sports Monte Carlo simulator using [duckdb](https://duckdb.org/), [dbt](https://www.getdbt.com/), and [evidence](https://evidence.dev/). The project is built and run about once per day in a github action. You can learn more about this on the [original blog post](https://duckdb.org/2022/10/12/modern-data-stack-in-a-box.html) or on [the about page](/about).

### Want to track what I am cooking up next? Join the email list.

<label>
    <input
        type="email" 
        placeholder="Type your email..." 
        bind:value="{email}" 
        style="border: 2px solid #bd4e35; border-radius: 5px;"
    />
</label>

<a href="{prefilledLink}" target="_blank" on:click={handleClick}>
    <button class="submit-button" disabled={isClicked}>Subscribe</button>
</a>

## [NBA Model](/nba)

## [NFL Model](/nfl)

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
        background-color: #bd4e35;
        border: none;
        color: white;
        padding: 2px 6px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-size: 14px;
        margin: 4px 2px;
        cursor: pointer;
    }
</style>
