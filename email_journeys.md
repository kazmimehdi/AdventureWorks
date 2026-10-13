# Winery email journey drafts

**These journey rules and messages are drafts for client review only.** The
AdventureWorks sample has no winery club-signup, club-membership, or marketing
consent data; those events and attributes must come from the winery's systems.
Before any real send, confirm audience, brand voice, consent, offer terms, and
any winery-required age gating. Every marketing email must include the
required unsubscribe link.

## Welcome

- **Trigger:** A customer signs up for the wine club.
- **Segment:** New club members, regardless of spend-based AdventureWorks tier.
- **Timing:** Send immediately after confirmed signup.
- **Exit conditions:** Exit if signup is withdrawn, the address is invalid, or
  marketing consent is absent or withdrawn.
- **Subject:** Welcome to the club, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, welcome to the {{WineryName}} wine club!
  We’re delighted to have you with us. Your membership opens the door to
  winery news, member releases, and experiences selected for our club.
  Cheers, {{WineryName}}
- **Success metric:** Welcome-to-first-club-order conversion within 30 days.

## Club anniversary

- **Trigger:** Anniversary of the customer's wine-club join date, not the
  first order date.
- **Segment:** Current club members in any membership level.
- **Timing:** Send on the join-date anniversary. Confirm active membership,
  consent, and that this year's anniversary message has not already been sent.
- **Exit conditions:** Exit if membership ended before the send date, consent
  was withdrawn, or the customer is suppressed from marketing.
- **Subject:** Celebrating another year together, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, happy {{MembershipYears}}-year
  anniversary with the {{WineryName}} wine club! Thank you for being part of
  our community. We’re looking forward to sharing another year of memorable
  wines with you. Cheers, {{WineryName}}
- **Success metric:** Club renewal rate among members who received the
  anniversary journey.

## Gold customer win-back

- **Trigger:** A customer has placed no order in the last 90 days.
- **Segment:** Gold in `Sales.vCustomerTier` (a spend-based sample proxy);
  for the winery, use actual membership level and last-order date instead.
- **Timing:** Send on day 90 of inactivity. Re-check membership/tier,
  last-order date, consent, and suppression immediately before sending.
- **Exit conditions:** Exit if an order is placed, consent is withdrawn, the
  customer is suppressed, or the customer is no longer in the target segment.
- **Subject:** We’d love to welcome you back, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, we’ve missed sharing our latest wines and
  winery news with you. If you’re ready to visit again, we’d be delighted to
  help you discover what’s new. We hope to see you soon. Cheers, {{WineryName}}
- **Success metric:** Reorder rate within 30 days of the win-back message.

## Join the club

- **Trigger:** A non-member completes a second purchase.
- **Segment:** Customers with at least two recorded purchases who are not
  current wine-club members; exclude customers without marketing consent.
- **Timing:** Send three days after the second order is fulfilled. Re-check
  order count and membership status before sending.
- **Exit conditions:** Exit if the customer joins the club, places an order
  that makes the nudge stale, withdraws consent, or becomes suppressed.
- **Subject:** Make your next bottle a little more special, {{FirstName}}
- **Draft body:** Hi {{FirstName}}, it’s wonderful to see you back. If you’d
  like to enjoy more from {{WineryName}}, our wine club offers members
  {{ApprovedMemberBenefits}}. Take a look and see whether it’s right for you.
  Cheers, {{WineryName}}
- **Success metric:** Club signup rate within 30 days of the nudge.

## Journey collision and suppression rules

- Apply global opt-out, consent, invalid-address, and client-approved age
  eligibility rules before enrolling or sending any journey.
- Allow at most one marketing journey email to a customer in a rolling
  seven-day window. Prioritize club welcome, then club anniversary, then club
  join nudge, then win-back. Delay a lower-priority send until the cooldown
  ends, then recheck its trigger and exit conditions; suppress it if stale.
- A confirmed club signup takes priority over the club-join nudge and exits
  that nudge immediately. A completed order exits win-back.
- De-duplicate events and enforce one send per customer per journey event
  (and per anniversary year). Recheck exit conditions just before send time.
