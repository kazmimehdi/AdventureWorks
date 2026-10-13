# Winery email journey drafts

**These are draft messages and journey rules for client review only.** Confirm
the winery's audience, brand voice, consent rules, age restrictions, timing,
and offer terms before implementation or sending.

## Welcome

- **Trigger:** A customer's first recorded order is placed.
- **Segment:** Any customer tier in `Sales.vCustomerTier`; use the current tier
  to tailor product recommendations, not to gate the welcome.
- **Timing:** Send one day after the order confirmation, suppressing customers
  who have not consented to marketing.
- **Subject:** Welcome to the winery, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, welcome! We’re glad you found us. Explore
  the wines and stories that make our winery special, and look out for notes
  chosen with you in mind. We hope you enjoy your first order. Cheers, {{WineryName}}

## Customer anniversary

- **Trigger:** Anniversary of the customer's first recorded order date.
- **Segment:** All tiers in `Sales.vCustomerTier`; personalize the message by
  tier and relationship history.
- **Timing:** On the anniversary, after checking marketing consent and that
  the customer has not already received this year's anniversary message.
- **Subject:** A year of good taste, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, it’s been a year since your first order
  with us. Thank you for being part of our winery community. We’d love to
  help you find something special for the occasion. Cheers, {{WineryName}}

## Gold customer win-back

- **Trigger:** A Gold customer has placed no order in the last 90 days.
- **Segment:** `CustomerTier = 'Gold'` in `Sales.vCustomerTier`, with no order
  in the preceding 90 days. Re-check the segment immediately before sending.
- **Timing:** Send on day 90 of inactivity; send at most once per inactivity
  period and suppress if the customer has ordered or opted out.
- **Subject:** We’d love to welcome you back, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, we’ve missed sharing our latest wines and
  winery news with you. If you’re ready to visit again, we’d be delighted to
  help you discover what’s new. We hope to see you soon. Cheers, {{WineryName}}
