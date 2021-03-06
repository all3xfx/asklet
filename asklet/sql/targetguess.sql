/*
Finds the sense with most overlap to a senseless subject.
*/
DROP VIEW IF EXISTS asklet_targetguess;
CREATE VIEW asklet_targetguess
AS
select
    t1.domain_id,
    t1.conceptnet_subject as ambiguous_subject,
    t2.pos,
    t2.conceptnet_subject as unambiguous_subject,
    /*
    q1.conceptnet_predicate,
    q1.conceptnet_object,
    q2.conceptnet_object,
    */
    SUM(tqw1.prob * tqw2.prob)/COUNT(*) as avg_prob
from asklet_targetquestionweight as tqw1
inner join asklet_target as t1 on
        t1.id = tqw1.target_id
    and t1.sense is null
inner join asklet_question as q1 on
        q1.id = tqw1.question_id
--    and q1.sense is null
left outer join asklet_target as t2 on
        t2.word = t1.word
    and t2.sense is not null
    and t2.language = t1.language
    and t2.domain_id = t1.domain_id
left outer join asklet_question as q2 on
        q2.word = q1.word
    and q2.sense is not null
    and q2.language = q1.language
    and q2.domain_id = q1.domain_id
    and q2.conceptnet_predicate = q1.conceptnet_predicate
left outer join asklet_targetquestionweight as tqw2 on
        tqw2.target_id = t2.id
    and tqw2.question_id = q2.id
where tqw2.id is not null
--and t1.word = 'cat'
group by 
    t1.domain_id,
    t1.conceptnet_subject,
    t2.pos,
    t2.conceptnet_subject
order by domain_id, ambiguous_subject, avg_prob desc;
